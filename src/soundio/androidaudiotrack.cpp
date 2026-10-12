#include "soundio/androidaudiotrack.h"

#include <QJniEnvironment>
#include <QtCore/qcoreapplication_platform.h>
#include <android/log.h>
#include <chrono>
#include "control/controlobject.h"
#include "soundio/soundmanager.h"
#include "soundio/audioframewriter.h"
#include "waveform/visualplayposition.h"

namespace mixxx::android {

AudioTrackStream::AudioTrackStream() = default;

AudioTrackStream::~AudioTrackStream() {
    close();
}

bool AudioTrackStream::open(int deviceId, int sampleRate, int frames, Render render) {
    m_buffer.resize(frames * 4);
    m_track = QJniObject::callStaticObjectMethod("org/mixxx/AudioTrackBridge",
            "create",
            "(Landroid/content/Context;IIII)Lorg/mixxx/AudioTrackBridge;",
            QNativeInterface::QAndroidApplication::context().object(),
            deviceId,
            sampleRate,
            4,
            frames);
    if (!m_track.isValid() || !m_track.callMethod<jboolean>("start", "()Z")) {
        close();
        return false;
    }
    m_running.store(true);
    m_thread = std::thread([this, sampleRate, render = std::move(render)] {
        QJniEnvironment env;
        QJniObject::callStaticMethod<void>("android/os/Process", "setThreadPriority", "(I)V", -16);
#if defined(__aarch64__)
        uint64_t fpcr;
        asm volatile("mrs %0, FPCR" : "=r"(fpcr));
        fpcr |= uint64_t{1} << 24;
        asm volatile("msr FPCR, %0" : : "r"(fpcr));
#endif
        const auto cls = env->GetObjectClass(m_track.object());
        const auto write = env->GetMethodID(cls, "write", "(Ljava/nio/ByteBuffer;II)I");
        const auto head = env->GetMethodID(cls, "playbackHead", "()I");
        const auto underruns = env->GetMethodID(cls, "underrunCount", "()I");
        env->DeleteLocalRef(cls);
        const jint bytes = static_cast<jint>(m_buffer.size() * sizeof(CSAMPLE));
        const auto buffer = env->NewDirectByteBuffer(m_buffer.data(), bytes);
        uint64_t writtenFrames = 0;
        uint64_t playedFrames = 0;
        uint32_t previousHead = 0;
        int previousUnderruns = 0;
        while (m_running.load(std::memory_order_acquire)) {
            const uint32_t currentHead = env->CallIntMethod(m_track.object(), head);
            playedFrames += static_cast<uint32_t>(currentHead - previousHead);
            previousHead = currentHead;
            const auto queued = writtenFrames > playedFrames ? writtenFrames - playedFrames : 0;
            render(m_buffer.data(), static_cast<double>(queued) / sampleRate);
            const auto result = mixxx::audio::writeFrames(bytes, 4 * sizeof(CSAMPLE),
                    [this] { return m_running.load(std::memory_order_acquire); },
                    [&](int offset, int remaining) {
                        const auto count = env->CallIntMethod(m_track.object(), write, buffer, offset, remaining);
                        if (env->ExceptionCheck()) { env->ExceptionClear(); return jint{-1}; }
                        if (count > 0) { writtenFrames += count / (4 * sizeof(CSAMPLE)); }
                        return count;
                    });
            if (result == mixxx::audio::WriteResult::Error) {
                m_running.store(false, std::memory_order_release);
                __android_log_write(ANDROID_LOG_ERROR, "MixxxAudioRoutes", "USB AudioTrack write failed; pausing session");
                QJniObject::callStaticMethod<void>("org/mixxx/HardwareBridge", "outputFailed", "()V");
                break;
            }
            const int currentUnderruns = env->CallIntMethod(m_track.object(), underruns);
            if (currentUnderruns > previousUnderruns) { m_underruns.fetch_add(currentUnderruns - previousUnderruns); }
            previousUnderruns = currentUnderruns;
        }
        env->DeleteLocalRef(buffer);
    });
    return true;
}

void AudioTrackStream::close() {
    m_running.store(false, std::memory_order_release);
    if (m_track.isValid()) {
        m_track.callMethod<void>("interrupt", "()V");
    }
    if (m_thread.joinable()) {
        m_thread.join();
    }
    if (m_track.isValid()) {
        m_track.callMethod<void>("close", "()V");
        m_track = QJniObject();
    }
}

int AudioTrackStream::bufferFrames() const {
    return m_track.isValid() ? m_track.callMethod<jint>("bufferFrames", "()I") : 0;
}

int AudioTrackStream::takeUnderruns() { return m_underruns.exchange(0); }

UsbSoundDevice::UsbSoundDevice(UserSettingsPointer config, SoundManager* manager,
        int deviceId, const QString& name, int sampleRate)
        : SoundDevice(config, manager),
          m_androidId(deviceId),
          m_defaultSampleRate(mixxx::audio::SampleRate(sampleRate)),
          m_latencyUsage(QStringLiteral("[App]"), QStringLiteral("audio_latency_usage")) {
    m_deviceId.name = name;
    m_deviceId.deviceIndex = deviceId;
    m_strDisplayName = name;
    m_hostAPI = SoundManagerConfig::kAPIOboe;
    m_numOutputChannels = mixxx::audio::ChannelCount(4);
    m_numInputChannels = mixxx::audio::ChannelCount(0);
    m_sampleRate = m_defaultSampleRate;
}

UsbSoundDevice::~UsbSoundDevice() {
    close();
}

SoundDeviceStatus UsbSoundDevice::open(bool isClockReference, int syncBuffers) {
    Q_UNUSED(syncBuffers);
    if (!isClockReference || !m_audioInputs.isEmpty() || m_configFramesPerBuffer <= 0) {
        m_error = QStringLiteral("Use the USB controller as the main four-channel output without inputs");
        return SoundDeviceStatus::Error;
    }
    m_renderSeconds = 0;
    m_renderFrames = 0;
    m_stream = std::make_unique<AudioTrackStream>();
    if (!m_stream->open(m_androidId, static_cast<int>(m_sampleRate.toDouble()),
                m_configFramesPerBuffer, [this](CSAMPLE* output, double latency) { render(output, latency); })) {
        m_stream.reset();
        m_error = QStringLiteral("Android could not open four independent USB channels");
        return SoundDeviceStatus::Error;
    }
    ControlObject::set(ConfigKey(QStringLiteral("[App]"), QStringLiteral("output_latency_ms")),
            1000.0 * m_stream->bufferFrames() / m_sampleRate.toDouble());
    ControlObject::set(ConfigKey(QStringLiteral("[App]"), QStringLiteral("samplerate")), m_sampleRate);
    for (const auto& output : m_audioOutputs) {
        const auto channels = output.getChannelGroup();
        const auto message = QStringLiteral("USB output route: %1 channels=%2-%3")
                                     .arg(output.getString())
                                     .arg(channels.getChannelBase() + 1)
                                     .arg(channels.getChannelBase() + channels.getChannelCount().value());
        __android_log_write(ANDROID_LOG_INFO, "MixxxAudioRoutes", message.toUtf8().constData());
    }
    return SoundDeviceStatus::Ok;
}

void UsbSoundDevice::render(CSAMPLE* output, double latency) {
    m_timer.start();
    VisualPlayPosition::setCallbackEntryToDacSecs(latency, m_timer);
    if (m_stream->takeUnderruns() > 0) { m_pSoundManager->underflowHappened(1); }
    m_pSoundManager->processUnderflowHappened(m_configFramesPerBuffer);
    m_pSoundManager->readProcess(m_configFramesPerBuffer);
    m_pSoundManager->onDeviceOutputCallback(m_configFramesPerBuffer);
    composeOutputBuffer(output, m_configFramesPerBuffer, 0, 4);
    m_pSoundManager->writeProcess(m_configFramesPerBuffer);
    m_renderSeconds += m_timer.elapsed().toDoubleSeconds();
    m_renderFrames += m_configFramesPerBuffer;
    if (m_renderFrames >= m_sampleRate.toDouble() / 30) {
        m_latencyUsage.set(m_renderSeconds * m_sampleRate.toDouble() / m_renderFrames);
        m_renderSeconds = 0;
        m_renderFrames = 0;
    }
}

SoundDeviceStatus UsbSoundDevice::close() {
    if (m_stream) { m_stream->close(); }
    m_stream.reset();
    return SoundDeviceStatus::Ok;
}

bool UsbSoundDevice::isOpen() const { return m_stream != nullptr; }
void UsbSoundDevice::readProcess(SINT frames) { Q_UNUSED(frames); }
void UsbSoundDevice::writeProcess(SINT frames) { Q_UNUSED(frames); }
QString UsbSoundDevice::getError() const { return m_error; }
mixxx::audio::SampleRate UsbSoundDevice::getDefaultSampleRate() const { return m_defaultSampleRate; }

}
