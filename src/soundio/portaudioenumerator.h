#pragma once

#include <portaudio.h>

#include <QList>

#include "preferences/usersettings.h"
#include "soundio/sounddevice.h"
#include "soundio/sounddeviceenumerator.h"
#include "soundio/sounddeviceportaudio.h"

class PortAudioEnumerator : public SoundDeviceEnumerator {
  public:
    PortAudioEnumerator(UserSettingsPointer config,
            SoundManager* sm);
    ~PortAudioEnumerator() override;

    std::vector<SoundDevicePointer> queryDevices() const override;

    QList<QString> getAPIs() const override {
        return m_apis;
    }

    QList<mixxx::audio::SampleRate> getSampleRates(bool jackSampleRate) const override;

    void initialize() override;
    void deinitialize() override;

  private:
    void setJACKName() const;

    std::vector<SoundDevicePointer> m_devices;
    mixxx::audio::SampleRate m_jackSampleRate;
#ifdef Q_OS_ANDROID
    // Tracks whether the devices enumerated from AudioManager were already
    // handed to PortAudio in this session. Reset on deinitialize so that a
    // re-enumeration after a USB hot-plug registers every device from scratch
    // instead of skipping them all.
    bool m_oboeRegistered = false;
#endif

    UserSettingsPointer m_pConfig;
    SoundManager* m_pSoundManager;
    QList<QString> m_apis;
};
