#pragma once

#include <QObject>
#include <memory>
#include <vector>

class ControlProxy;
class QTimer;
class SoundManager;
class ControllerManager;

namespace mixxx {
namespace android {

/// Requests Android audio focus while any deck plays and pauses all decks when
/// focus is taken by another app (phone call, other media player).
class AudioFocus : public QObject {
    Q_OBJECT

  public:
    explicit AudioFocus(SoundManager* soundManager, ControllerManager* controllerManager,
            QObject* pParent = nullptr, bool diagnostics = false);
    ~AudioFocus() override;

    void handleFocusChange(int focusChange);
    void handleHardwareChange(int flags);
    void stopPlayback();

  private:
    void refreshPlayers();
    void updatePlayingState();
    void pauseAllPlayers();
    void abandonFocus();
    void logAudioLevels();

    std::vector<std::unique_ptr<ControlProxy>> m_playControls;
    std::vector<std::unique_ptr<ControlProxy>> m_playerCountControls;
    std::unique_ptr<QTimer> m_pDiagnosticTimer;
    bool m_hasFocus = false;
    bool m_focusRequested = false;
    bool m_pausingPlayers = false;
    SoundManager* m_soundManager;
    ControllerManager* m_controllerManager;
    std::unique_ptr<QTimer> m_pHardwareTimer;
    int m_hardwareChanges = 0;
    int m_transportRetries = 0;
};

/// Called from the Java listener thread; forwards the change to the Qt main thread.
void audioFocusChanged(int focusChange);
void hardwareChanged(int flags);
void pauseSession();

} // namespace android
} // namespace mixxx
