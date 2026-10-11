#include "soundio/androidaudiofocus.h"

#include <QCoreApplication>
#include <QJniObject>
#include <QTimer>
#include <QtCore/qcoreapplication_platform.h>
#include <android/log.h>
#include <utility>

#include "control/controlobject.h"
#include "control/controlproxy.h"
#include "moc_androidaudiofocus.cpp"

namespace {
constexpr int kMaxDecks = 16;
// android.media.AudioManager.AUDIOFOCUS_LOSS and AUDIOFOCUS_LOSS_TRANSIENT
constexpr int kFocusLoss = -1;
constexpr int kFocusLossTransient = -2;
constexpr int kFocusLossTransientCanDuck = -3;
constexpr const char* kBridgeClass = "org/mixxx/AudioFocusBridge";

mixxx::android::AudioFocus* s_pAudioFocus = nullptr;
} // namespace

namespace mixxx {
namespace android {

AudioFocus::AudioFocus(QObject* pParent, bool diagnostics)
        : QObject(pParent) {
    s_pAudioFocus = this;

    const QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (context.isValid()) {
        QJniObject::callStaticMethod<void>(kBridgeClass,
                "init",
                "(Landroid/content/Context;)V",
                context);
    }

    for (int deck = 1; deck <= kMaxDecks; ++deck) {
        const ConfigKey key(QStringLiteral("[Channel%1]").arg(deck), QStringLiteral("play"));
        if (!ControlObject::exists(key)) {
            continue;
        }
        auto pPlay = std::make_unique<ControlProxy>(key, this);
        pPlay->connectValueChanged(this, &AudioFocus::updatePlayingState);
        m_playControls.push_back(std::move(pPlay));
    }

    if (diagnostics) {
        m_pDiagnosticTimer = std::make_unique<QTimer>(this);
        m_pDiagnosticTimer->setInterval(5000);
        connect(m_pDiagnosticTimer.get(), &QTimer::timeout, this, &AudioFocus::logAudioLevels);
        m_pDiagnosticTimer->start();
    }
}

AudioFocus::~AudioFocus() {
    QJniObject::callStaticMethod<void>(kBridgeClass, "abandon", "()V");
    s_pAudioFocus = nullptr;
}

void AudioFocus::updatePlayingState() {
    bool anyPlaying = false;
    for (const auto& pPlay : m_playControls) {
        if (pPlay->get() > 0.0) {
            anyPlaying = true;
            break;
        }
    }

    if (anyPlaying && !m_hasFocus) {
        m_hasFocus = QJniObject::callStaticMethod<jboolean>(kBridgeClass, "request", "()Z");
        if (!m_hasFocus) {
            qWarning() << "Android audio focus denied; pausing decks";
            pauseAllDecks();
        }
    } else if (!anyPlaying && m_hasFocus) {
        QJniObject::callStaticMethod<void>(kBridgeClass, "abandon", "()V");
        m_hasFocus = false;
    }
}

void AudioFocus::handleFocusChange(int focusChange) {
    if (focusChange == kFocusLoss || focusChange == kFocusLossTransient ||
            focusChange == kFocusLossTransientCanDuck) {
        // Another app took the audio output (e.g. a phone call): stop the mix
        // instead of playing over it, the DJ resumes manually.
        m_hasFocus = false;
        pauseAllDecks();
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

void AudioFocus::pauseAllDecks() {
    for (const auto& pPlay : m_playControls) {
        pPlay->set(0.0);
    }
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
