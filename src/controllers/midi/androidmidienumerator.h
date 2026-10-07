#pragma once

#include "controllers/midi/midienumerator.h"

/// Discovers MIDI controllers exposed by the android.media.midi framework
/// through the org.mixxx.MidiBridge Java helper.
class AndroidMidiEnumerator : public MidiEnumerator {
    Q_OBJECT
  public:
    AndroidMidiEnumerator();
    ~AndroidMidiEnumerator() override;

    QList<Controller*> queryDevices() override;

  private:
    QList<Controller*> m_devices;
};
