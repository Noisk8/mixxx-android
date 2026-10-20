#pragma once

#include <QtCore/QString>
#include <QtCore/QDebug>
#include <functional>
#include <utility>

namespace mixxx {
namespace android {

enum class DeviceLifecycleState {
    Unplugged,
    Permission,
    Opened,
    Streaming,
    Failed,
    Removed
};

inline const char* deviceLifecycleStateToString(DeviceLifecycleState state) {
    switch (state) {
        case DeviceLifecycleState::Unplugged:
            return "Unplugged";
        case DeviceLifecycleState::Permission:
            return "Permission";
        case DeviceLifecycleState::Opened:
            return "Opened";
        case DeviceLifecycleState::Streaming:
            return "Streaming";
        case DeviceLifecycleState::Failed:
            return "Failed";
        case DeviceLifecycleState::Removed:
            return "Removed";
    }
    return "Unknown";
}

/// Explicit state machine tracking USB Controller & Audio hot-plug lifecycle.
///
/// NOTE: Currently this state machine is OBSERVATIONAL (it audits and logs state
/// transitions for the global controller/audio device lifecycle in Logcat, but does
/// not directly orchestrate isolated recovery per subsystem). In future iterations,
/// transactional state will be tracked per subsystem (Audio / MIDI / HID).
class ControllerAudioStateMachine {
  public:
    using StateChangedCallback = std::function<void(DeviceLifecycleState newState,
            DeviceLifecycleState oldState,
            const QString& reason)>;

    explicit ControllerAudioStateMachine(StateChangedCallback callback = nullptr)
            : m_state(DeviceLifecycleState::Unplugged), m_callback(std::move(callback)) {
        s_pInstance = this;
    }

    ~ControllerAudioStateMachine() {
        if (s_pInstance == this) {
            s_pInstance = nullptr;
        }
    }

    static ControllerAudioStateMachine* instance() {
        return s_pInstance;
    }

    DeviceLifecycleState state() const {
        return m_state;
    }

    void setCallback(StateChangedCallback callback) {
        m_callback = std::move(callback);
    }

    bool transitionTo(DeviceLifecycleState newState, const QString& reason = QString()) {
        const DeviceLifecycleState oldState = m_state;
        if (oldState == newState) {
            return true;
        }

        // Validate state transitions
        bool valid = false;
        switch (oldState) {
            case DeviceLifecycleState::Unplugged:
                valid = (newState == DeviceLifecycleState::Permission ||
                         newState == DeviceLifecycleState::Opened);
                break;
            case DeviceLifecycleState::Permission:
                valid = (newState == DeviceLifecycleState::Opened ||
                         newState == DeviceLifecycleState::Failed ||
                         newState == DeviceLifecycleState::Removed ||
                         newState == DeviceLifecycleState::Unplugged);
                break;
            case DeviceLifecycleState::Opened:
                valid = (newState == DeviceLifecycleState::Streaming ||
                         newState == DeviceLifecycleState::Failed ||
                         newState == DeviceLifecycleState::Removed ||
                         newState == DeviceLifecycleState::Unplugged);
                break;
            case DeviceLifecycleState::Streaming:
                valid = (newState == DeviceLifecycleState::Failed ||
                         newState == DeviceLifecycleState::Removed ||
                         newState == DeviceLifecycleState::Unplugged);
                break;
            case DeviceLifecycleState::Failed:
                valid = (newState == DeviceLifecycleState::Opened ||
                         newState == DeviceLifecycleState::Permission ||
                         newState == DeviceLifecycleState::Removed ||
                         newState == DeviceLifecycleState::Unplugged);
                break;
            case DeviceLifecycleState::Removed:
                // Allow direct re-opening or re-permission on hot-plug re-connection
                valid = (newState == DeviceLifecycleState::Unplugged ||
                         newState == DeviceLifecycleState::Permission ||
                         newState == DeviceLifecycleState::Opened);
                break;
        }

        if (!valid) {
            qWarning() << "Invalid lifecycle state transition from"
                       << deviceLifecycleStateToString(oldState) << "to"
                       << deviceLifecycleStateToString(newState) << "reason:" << reason;
            return false;
        }

        m_state = newState;
        qInfo() << "Lifecycle state transition:"
                << deviceLifecycleStateToString(oldState) << "->"
                << deviceLifecycleStateToString(newState) << "reason:" << reason;
        if (m_callback) {
            m_callback(newState, oldState, reason);
        }
        return true;
    }

  private:
    DeviceLifecycleState m_state;
    StateChangedCallback m_callback;
    static inline ControllerAudioStateMachine* s_pInstance = nullptr;
};

} // namespace android
} // namespace mixxx
