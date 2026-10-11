#pragma once

#include <QObject>
#include <memory>
#include <vector>

class ControlProxy;
class QTimer;

namespace mixxx {
namespace android {

/// Requests Android audio focus while any deck plays and pauses all decks when
/// focus is taken by another app (phone call, other media player).
class AudioFocus : public QObject {
    Q_OBJECT

  public:
    explicit AudioFocus(QObject* pParent = nullptr, bool diagnostics = false);
    ~AudioFocus() override;

    void handleFocusChange(int focusChange);

  private:
    void updatePlayingState();
    void pauseAllDecks();
    void logAudioLevels();

    std::vector<std::unique_ptr<ControlProxy>> m_playControls;
    std::unique_ptr<QTimer> m_pDiagnosticTimer;
    bool m_hasFocus = false;
};

/// Called from the Java listener thread; forwards the change to the Qt main thread.
void audioFocusChanged(int focusChange);

} // namespace android
} // namespace mixxx
