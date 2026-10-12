#pragma once

#include <QJniObject>
#include <atomic>
#include <functional>
#include <thread>
#include <vector>

#include "control/pollingcontrolproxy.h"
#include "soundio/sounddevice.h"
#include "util/performancetimer.h"
#include "util/types.h"

namespace mixxx::android {

class AudioTrackStream {
  public:
    using Render = std::function<void(CSAMPLE*, double)>;
    AudioTrackStream();
    ~AudioTrackStream();
    bool open(int deviceId, int sampleRate, int frames, Render render);
    void close();
    int bufferFrames() const;
    int takeUnderruns();

  private:
    QJniObject m_track;
    std::vector<CSAMPLE> m_buffer;
    std::atomic<bool> m_running{false};
    std::atomic<int> m_underruns{0};
    std::thread m_thread;
};

class UsbSoundDevice final : public SoundDevice {
  public:
    UsbSoundDevice(UserSettingsPointer config, SoundManager* manager,
            int deviceId, const QString& name, int sampleRate);
    ~UsbSoundDevice() override;
    SoundDeviceStatus open(bool isClockReference, int syncBuffers) override;
    SoundDeviceStatus close() override;
    bool isOpen() const override;
    void readProcess(SINT frames) override;
    void writeProcess(SINT frames) override;
    QString getError() const override;
    mixxx::audio::SampleRate getDefaultSampleRate() const override;

  private:
    void render(CSAMPLE* output, double latency);
    int m_androidId;
    mixxx::audio::SampleRate m_defaultSampleRate;
    std::unique_ptr<AudioTrackStream> m_stream;
    QString m_error;
    PollingControlProxy m_latencyUsage;
    PerformanceTimer m_timer;
    double m_renderSeconds = 0;
    int m_renderFrames = 0;
};

}
