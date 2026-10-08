#include "soundio/androidaudiofocus.h"

#include <QCoreApplication>
#include <QJniObject>
#include <QtCore/qcoreapplication_platform.h>
#include <utility>

#include "control/controlobject.h"
#include "control/controlproxy.h"
#include "moc_androidaudiofocus.cpp"

namespace {
constexpr int kMaxDecks = 16;
// android.media.AudioManager.AUDIOFOCUS_LOSS and AUDIOFOCUS_LOSS_TRANSIENT
constexpr int kFocusLoss = -1;
constexpr int kFocusLossTransient = -2;
constexpr const char* kBridgeClass = "org/mixxx/AudioFocusBridge";

mixxx::android::AudioFocus* s_pAudioFocus = nullptr;
} // namespace

namespace mixxx {
namespace android {

AudioFocus::AudioFocus(QObject* pParent)
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
}

AudioFocus::~AudioFocus() {
    if (m_hasFocus) {
        QJniObject::callStaticMethod<void>(kBridgeClass, "abandon", "()V");
    }
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
    } else if (!anyPlaying && m_hasFocus) {
        QJniObject::callStaticMethod<void>(kBridgeClass, "abandon", "()V");
        m_hasFocus = false;
    }
}

void AudioFocus::handleFocusChange(int focusChange) {
    if (focusChange == kFocusLoss || focusChange == kFocusLossTransient) {
        // Another app took the audio output (e.g. a phone call): stop the mix
        // instead of playing over it, the DJ resumes manually.
        m_hasFocus = false;
        pauseAllDecks();
    } else if (focusChange > 0) {
        m_hasFocus = true;
    }
    // Ducking (AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK) keeps playing.
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
