#include "soundio/androidaudiofocus.h"

#include <QtCore/qcoreapplication_platform.h>
#include <android/log.h>

#include <QCoreApplication>
#include <QJniObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QScopedValueRollback>
#include <QTimer>
#include <algorithm>
#include <utility>

#include "control/controlobject.h"
#include "control/controlproxy.h"
#include "controllers/controllermanager.h"
#include "soundio/androidusbremap.h"
#include "soundio/soundmanager.h"
#include "moc_androidaudiofocus.cpp"

namespace {
// android.media.AudioManager.AUDIOFOCUS_LOSS and AUDIOFOCUS_LOSS_TRANSIENT
constexpr int kFocusLoss = -1;
constexpr int kFocusLossTransient = -2;
constexpr int kFocusLossTransientCanDuck = -3;
constexpr const char* kBridgeClass = "org/mixxx/AudioFocusBridge";

mixxx::android::AudioFocus* s_pAudioFocus = nullptr;
} // namespace

namespace mixxx {
namespace android {

AudioFocus::AudioFocus(SoundManager* soundManager, ControllerManager* controllerManager,
        QObject* pParent, bool diagnostics)
        : QObject(pParent), m_soundManager(soundManager), m_controllerManager(controllerManager) {
    s_pAudioFocus = this;

    const QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (context.isValid()) {
        QJniObject::callStaticMethod<void>(kBridgeClass,
                "init",
                "(Landroid/content/Context;)V",
                context);
        QJniObject::callStaticMethod<void>("org/mixxx/HardwareBridge", "init",
                "(Landroid/content/Context;)V", context);
    }

    m_pHardwareTimer = std::make_unique<QTimer>(this);
    m_pHardwareTimer->setSingleShot(true);
    m_pHardwareTimer->setInterval(1000);
    connect(m_pHardwareTimer.get(), &QTimer::timeout, this, [this] {
        const int changes = std::exchange(m_hardwareChanges, 0);
        if (changes & 1) {
            auto config = m_soundManager->getConfig();
            m_soundManager->clearAndQueryDevices();
            const auto devices = m_soundManager->getDeviceList(config.getAPI(), true, true);
            std::vector<SoundDeviceId> available;
            available.reserve(devices.size());
            for (const auto& device : devices) {
                available.push_back(device->getDeviceId());
            }
            const auto remap = [&available](auto& routes) {
                auto restored = routes;
                restored.clear();
                for (auto it = routes.cbegin(); it != routes.cend(); ++it) {
                    restored.insert(resolveRecoveredDeviceId(it.key(), available), it.value());
                }
                routes = std::move(restored);
            };
            remap(config.getOutputsRef());
            remap(config.getInputsRef());
            const auto status = m_soundManager->setConfig(config);
            qInfo() << "Android USB audio recovery status:" << static_cast<int>(status);
        }
        if (changes & 2) {
            m_controllerManager->reconnectAndroidMidi();
        }
    });

    for (const auto* name : {"num_decks", "num_samplers", "num_preview_decks"}) {
        const ConfigKey key(QStringLiteral("[App]"), QString::fromLatin1(name));
        if (!ControlObject::exists(key)) {
            continue;
        }
        auto pCount = std::make_unique<ControlProxy>(key, this);
        pCount->connectValueChanged(this, &AudioFocus::refreshPlayers);
        m_playerCountControls.push_back(std::move(pCount));
    }
    refreshPlayers();

    {
        m_pDiagnosticTimer = std::make_unique<QTimer>(this);
        m_pDiagnosticTimer->setInterval(diagnostics ? 5000 : 30000);
        connect(m_pDiagnosticTimer.get(), &QTimer::timeout, this, &AudioFocus::logAudioLevels);
        m_pDiagnosticTimer->start();
    }
}

AudioFocus::~AudioFocus() {
    QJniObject::callStaticMethod<void>("org/mixxx/HardwareBridge", "shutdown", "()V");
    abandonFocus();
    s_pAudioFocus = nullptr;
}

void AudioFocus::refreshPlayers() {
    for (const auto& type : {std::pair{"num_decks", "Channel"},
                 std::pair{"num_samplers", "Sampler"},
                 std::pair{"num_preview_decks", "PreviewDeck"}}) {
        const ConfigKey countKey(QStringLiteral("[App]"), QString::fromLatin1(type.first));
        if (!ControlObject::exists(countKey)) {
            continue;
        }
        const int count = static_cast<int>(ControlObject::get(countKey));
        for (int index = 1; index <= count; ++index) {
            const ConfigKey key(QStringLiteral("[%1%2]")
                                        .arg(QString::fromLatin1(type.second))
                                        .arg(index),
                    QStringLiteral("play"));
            if (!ControlObject::exists(key) ||
                    std::any_of(m_playControls.cbegin(), m_playControls.cend(), [&key](const auto& pPlay) { return pPlay->getKey() == key; })) {
                continue;
            }
            auto pPlay = std::make_unique<ControlProxy>(key, this);
            pPlay->connectValueChanged(this, &AudioFocus::updatePlayingState);
            m_playControls.push_back(std::move(pPlay));
        }
    }
    updatePlayingState();
}

void AudioFocus::updatePlayingState() {
    if (m_pausingPlayers) {
        return;
    }
    bool anyPlaying = false;
    for (const auto& pPlay : m_playControls) {
        if (pPlay->get() > 0.0) {
            anyPlaying = true;
            break;
        }
    }

    if (anyPlaying && !m_hasFocus) {
        const bool service = QJniObject::callStaticMethod<jboolean>("org/mixxx/PlaybackService", "setActive",
                "(Landroid/content/Context;Z)Z", QNativeInterface::QAndroidApplication::context().object(), true);
        if (!service) {
            pauseAllPlayers();
            abandonFocus();
            return;
        }
        m_hasFocus = QJniObject::callStaticMethod<jboolean>(kBridgeClass, "request", "()Z");
        m_focusRequested = m_hasFocus;
        if (!m_hasFocus) {
            qWarning() << "Android audio focus denied; pausing players";
            pauseAllPlayers();
            abandonFocus();
        }
    } else if (!anyPlaying) {
        abandonFocus();
    }
}

void AudioFocus::handleFocusChange(int focusChange) {
    if (!m_focusRequested) {
        return;
    }
    if (focusChange == kFocusLoss || focusChange == kFocusLossTransient) {
        // Another app took the audio output (e.g. a phone call): stop the mix
        // instead of playing over it, the DJ resumes manually.
        m_hasFocus = false;
        pauseAllPlayers();
        abandonFocus();
    } else if (focusChange == kFocusLossTransientCanDuck) {
        // Autonomously generated by an AI agent: a duck request is advisory
        // (usually a notification). Keep the DJ mix running and at full level;
        // only a real or transient focus loss may pause the decks.
        // End of comment autonomously generated by an AI agent.
        qInfo() << "Android audio focus duck request ignored while Mixxx plays";
    } else if (focusChange > 0) {
        m_hasFocus = true;
    }
}

void AudioFocus::logAudioLevels() {
    bool anyPlaying = false;
    for (const auto& pPlay : m_playControls) {
        anyPlaying |= pPlay->get() > 0.0;
    }
    if (!anyPlaying) {
        return;
    }

    QJniObject::callStaticMethod<void>(kBridgeClass, "logOutputState", "()V");
    QJniObject::callStaticMethod<void>("org/mixxx/AudioTrackBridge", "logAll", "()V");
    const auto mixerValue = [](const char* name) {
        const ConfigKey key(QStringLiteral("[Master]"), QString::fromLatin1(name));
        return ControlObject::exists(key)
                ? QString::number(ControlObject::get(key), 'g', 8)
                : QStringLiteral("missing");
    };
    const auto logLevels = [](const QString& message) {
        qDebug().noquote() << message;
        __android_log_write(ANDROID_LOG_INFO, "MixxxAudioLevels", message.toUtf8().constData());
    };
    logLevels(QStringLiteral("Android audio levels: focus=%1 mainGain=%2 mainVu=%3 "
                             "mainPeak=%4 headGain=%5 headMix=%6 balance=%7 "
                             "headEnabled=%8 headSplit=%9")
                      .arg(m_hasFocus)
                      .arg(mixerValue("gain"))
                      .arg(mixerValue("vu_meter"))
                      .arg(mixerValue("peak_indicator"))
                      .arg(mixerValue("headGain"))
                      .arg(mixerValue("headMix"))
                      .arg(mixerValue("balance"))
                      .arg(mixerValue("headEnabled"))
                      .arg(mixerValue("headSplit")));
    logLevels(QStringLiteral("Android engine: overloads=%1 renderUsage=%2 latencyMs=%3")
                      .arg(ControlObject::get(ConfigKey(QStringLiteral("[App]"), QStringLiteral("audio_latency_overload_count"))))
                      .arg(ControlObject::get(ConfigKey(QStringLiteral("[App]"), QStringLiteral("audio_latency_usage"))))
                      .arg(ControlObject::get(ConfigKey(QStringLiteral("[App]"), QStringLiteral("output_latency_ms")))));
    QJsonObject sample;
    sample.insert(QStringLiteral("type"), QStringLiteral("engine"));
    for (const auto* name : {"audio_latency_overload_count", "audio_latency_usage", "output_latency_ms"}) {
        sample.insert(QString::fromLatin1(name), ControlObject::get(ConfigKey(QStringLiteral("[App]"), QString::fromLatin1(name))));
    }
    sample.insert(QStringLiteral("headMix"), ControlObject::get(ConfigKey(QStringLiteral("[Master]"), QStringLiteral("headMix"))));
    QJniObject::callStaticMethod<void>("org/mixxx/SessionDiagnostics", "record", "(Ljava/lang/String;)V",
            QJniObject::fromString(QString::fromUtf8(QJsonDocument(sample).toJson(QJsonDocument::Compact))));
    for (const auto& pPlay : m_playControls) {
        const auto group = pPlay->getKey().group;
        const auto pfl = ControlObject::get(ConfigKey(group, QStringLiteral("pfl")));
        if (pPlay->get() <= 0.0 && pfl <= 0.0) {
            continue;
        }
        logLevels(QStringLiteral("Android audio deck: %1 pregain=%2 volume=%3 vu=%4 play=%5 pfl=%6")
                          .arg(group)
                          .arg(ControlObject::get(ConfigKey(group, QStringLiteral("pregain"))))
                          .arg(ControlObject::get(ConfigKey(group, QStringLiteral("volume"))))
                          .arg(ControlObject::get(ConfigKey(group, QStringLiteral("vu_meter"))))
                          .arg(pPlay->get())
                          .arg(pfl));
    }
}

void AudioFocus::pauseAllPlayers() {
    // Autonomously generated by an AI agent.
    // Changing play controls emits signals synchronously. Suppress a new focus
    // request until every player has stopped after a denial or focus loss.
    // End of comment autonomously generated by an AI agent.
    const QScopedValueRollback<bool> pausing(m_pausingPlayers, true);
    for (const auto& pPlay : m_playControls) {
        pPlay->set(0.0);
    }
}

void AudioFocus::abandonFocus() {
    QJniObject::callStaticMethod<jboolean>("org/mixxx/PlaybackService", "setActive",
            "(Landroid/content/Context;Z)Z", QNativeInterface::QAndroidApplication::context().object(), false);
    if (m_focusRequested) {
        QJniObject::callStaticMethod<void>(kBridgeClass, "abandon", "()V");
    }
    m_focusRequested = false;
    m_hasFocus = false;
}

void AudioFocus::stopPlayback() {
    pauseAllPlayers();
    abandonFocus();
}

void AudioFocus::handleHardwareChange(int flags) {
    if (flags & 4) {
        stopPlayback();
    }
    if (flags & 8) {
        if (++m_transportRetries > 3) {
            m_soundManager->closeActiveConfig();
            qWarning() << "USB output recovery failed repeatedly; reconnect the controller or apply sound preferences";
            return;
        }
    } else if (flags & 1) {
        m_transportRetries = 0;
    }
    m_hardwareChanges |= flags;
    m_pHardwareTimer->start();
}

void hardwareChanged(int flags) {
    QMetaObject::invokeMethod(qApp, [flags] {
        if (s_pAudioFocus) { s_pAudioFocus->handleHardwareChange(flags); }
    });
}

void pauseSession() {
    QMetaObject::invokeMethod(qApp, [] {
        if (s_pAudioFocus) { s_pAudioFocus->stopPlayback(); }
    });
}

void audioFocusChanged(int focusChange) {
    QMetaObject::invokeMethod(qApp, [focusChange] {
        if (s_pAudioFocus) {
            s_pAudioFocus->handleFocusChange(focusChange);
        }
    });
}

} // namespace android
} // namespace mixxx
