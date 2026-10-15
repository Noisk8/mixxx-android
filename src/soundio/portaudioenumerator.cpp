#include "soundio/portaudioenumerator.h"

#include <portaudio.h>

#include <QLibrary>
#include <QSharedPointer>

#include "audio/types.h"
#include "soundio/sounddevice.h"
#include "soundio/sounddeviceportaudio.h"
#include "util/versionstore.h"

#ifdef Q_OS_IOS
#include "soundio/soundmanagerios.h"
#elif defined(Q_OS_ANDROID)
#include <QtCore/private/qandroidextras_p.h>
#include <android/api-level.h>
#include <android/log.h>
#include <jni.h>
#include <pa_oboe.h>

#include <QJniObject>
#endif

typedef PaError (*SetJackClientName)(const char* name);

PortAudioEnumerator::PortAudioEnumerator(UserSettingsPointer config, SoundManager* sm)
        : m_pConfig(config),
          m_pSoundManager(sm) {
    initialize();
}

PortAudioEnumerator::~PortAudioEnumerator() {
    deinitialize();
}

void PortAudioEnumerator::initialize() {
    PaError err;
    if (m_initialized) {
        return;
    }

    m_jackSampleRate = mixxx::audio::SampleRate();

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    setJACKName();
#endif
#ifdef Q_OS_IOS
    mixxx::initializeAVAudioSession();
#elif defined(Q_OS_ANDROID)
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([this]() {
        QJniObject context = QNativeInterface::QAndroidApplication::context();
        QJniObject AUDIO_SERVICE =
                QJniObject::getStaticObjectField(
                        "android/content/Context",
                        "AUDIO_SERVICE",
                        "Ljava/lang/String;");
        auto audioManager = context.callObjectMethod("getSystemService",
                "(Ljava/lang/String;)Ljava/lang/Object;",
                AUDIO_SERVICE.object());
        if (!audioManager.isValid()) {
            qDebug() << "audioManager invalid";
            return;
        }
        qDebug() << "audioManager valid:" << audioManager.toString();

        jint GET_DEVICES_INPUTS =
                QJniObject::getStaticField<jint>(
                        "android/media/AudioManager",
                        "GET_DEVICES_INPUTS");
        jint GET_DEVICES_OUTPUTS =
                QJniObject::getStaticField<jint>(
                        "android/media/AudioManager",
                        "GET_DEVICES_OUTPUTS");

        auto const supportedFriendlyName = [](int type) -> std::optional<QString> {
            switch (type) {
            case 1: // AudioDeviceInfo.TYPE_BUILTIN_EARPIECE
                return tr("Earpiece");
            case 2: // AudioDeviceInfo.TYPE_BUILTIN_SPEAKER
                return tr("Speaker");
            case 4: // AudioDeviceInfo.TYPE_WIRED_HEADPHONES
                return tr("Wired headphones");
            case 3: // AudioDeviceInfo.TYPE_WIRED_HEADSET
                return tr("Wired headset");
            case 9: // AudioDeviceInfo.TYPE_HDMI
                return tr("HDMI");
            case 10: // AudioDeviceInfo.TYPE_HDMI_ARC
                return tr("HDMI audio return channel");
            case 15: // AudioDeviceInfo.TYPE_BUILTIN_MIC
                return tr("Microphone");
            case 25: // AudioDeviceInfo.TYPE_REMOTE_SUBMIX:
                return tr("Mixed");
            case 8:  // AudioDeviceInfo.TYPE_BLUETOOTH_A2DP
            case 11: // AudioDeviceInfo.TYPE_USB_DEVICE
            case 22: // AudioDeviceInfo.TYPE_USB_HEADSET
            case 13: // AudioDeviceInfo.TYPE_DOCK
            case 12: // AudioDeviceInfo.TYPE_USB_ACCESSORY
            case 26: // AudioDeviceInfo.TYPE_BLE_HEADSET
            case 27: // AudioDeviceInfo.TYPE_BLE_SPEAKER
            case 23: // AudioDeviceInfo.TYPE_HEARING_AID
                // supported, but no friendly name
                return QStringLiteral();
            default:
                // unsupported
                break;
            }
            return std::nullopt;
        };

        auto const parse = [this, supportedFriendlyName](PaOboe_Direction direction,
                                   QJniArray<QJniObject>& devices) {
            for (const auto& device : devices) {
                jint type = device->callMethod<jint>("getType");
                auto maybeName = supportedFriendlyName(type);
                if (!maybeName.has_value()) {
                    continue;
                }
                QString name = device->callObjectMethod("getProductName",
                                             "()Ljava/lang/CharSequence;")
                                       .toString();
                if (!maybeName.value().isEmpty()) {
                    name.append(QStringLiteral(": %1").arg(maybeName.value()));
                }
                int32_t id = device->callMethod<jint>("getId");
                auto channelCounts = device->callMethod<QJniArray<jint>>("getChannelCounts");
                // Android does not always report channel counts (e.g. built-in
                // speakers on many devices). Fall back to stereo instead of
                // dereferencing an empty range (undefined behavior).
                int channelCount = 2;
                if (!channelCounts.isEmpty()) {
                    channelCount = *std::max_element(
                            channelCounts.begin(), channelCounts.end());
                    if (channelCount < 1) {
                        channelCount = 2;
                    }
                }
                // Android does not always report supported sample rates either
                // (common for built-in output devices). Do not skip the device
                // in that case -- register it with a sensible default so the
                // device can be selected as an output.
                auto sampleRates = device->callMethod<QJniArray<jint>>("getSampleRates");
                int sampleRate = 48000;
                if (!sampleRates.isEmpty()) {
                    if (std::find(sampleRates.begin(), sampleRates.end(), 48000) !=
                            sampleRates.end()) {
                        sampleRate = 48000;
                    } else {
                        sampleRate = *sampleRates.cbegin();
                    }
                }
                qDebug() << "audioManager - Type:" << type
                         << "- Name:" << name
                         << "- ChannelCount:" << channelCount
                         << channelCounts.size()
                         << "- SampleRate:" << sampleRate;
                if (m_oboeRegistered) { continue; }
                auto result = PaOboe_RegisterDevice(name.toStdString().c_str(),
                        id,
                        direction,
                        channelCount,
                        sampleRate);
                if (result != paNoError) {
                    qWarning()
                            << "Error registering device to PortAudio:"
                            << Pa_GetErrorText(result);
                }
            }
        };

        auto inputDevices =
                audioManager.callMethod<QJniArray<QJniObject>>("getDevices",
                        "(I)[Landroid/media/AudioDeviceInfo;",
                        GET_DEVICES_INPUTS);
        qDebug() << "audioManager inputDevices:" << inputDevices.size();
        parse(PaOboe_Direction::Input, inputDevices);

        auto outputDevices =
                audioManager.callMethod<QJniArray<QJniObject>>("getDevices",
                        "(I)[Landroid/media/AudioDeviceInfo;",
                        GET_DEVICES_OUTPUTS);
        qDebug() << "audioManager outputDevices:" << outputDevices.size();
        parse(PaOboe_Direction::Output, outputDevices);

        QJniObject PROPERTY_OUTPUT_FRAMES_PER_BUFFER =
                QJniObject::getStaticField<jstring>(
                        "android/media/AudioManager",
                        "PROPERTY_OUTPUT_FRAMES_PER_BUFFER");
        auto outputFramePerBuffer =
                audioManager
                        .callMethod<jstring>("getProperty",
                                "(Ljava/lang/String;)Ljava/lang/String;",
                                PROPERTY_OUTPUT_FRAMES_PER_BUFFER)
                        .toString()
                        .toUInt();
        qDebug() << "audioManager outputFramePerBuffer:" << outputFramePerBuffer;
        PaOboe_SetNativeBufferSize(outputFramePerBuffer);
    }).waitForFinished();
    m_oboeRegistered = true;
    PaOboe_SetNumberOfBuffers(4);

#endif
    err = Pa_Initialize();
    m_initialized = true;

    if (err != paNoError) {
        qDebug() << "Error:" << Pa_GetErrorText(err);
        m_initialized = false;
        return;
    }

    int iNumDevices = Pa_GetDeviceCount();
    if (iNumDevices < 0) {
        qDebug() << "ERROR: Pa_CountDevices returned" << Pa_GetErrorText(iNumDevices);
        return;
    } else if (iNumDevices == 0) {
        qWarning() << "Pa_CountDevices returned no devices!";
    } else {
        qDebug() << "Pa_CountDevices found" << iNumDevices << "devices";
    }
    qDebug() << "Pa_GetHostApiCount returns" << Pa_GetHostApiCount();

    // PaDeviceInfo structs have a PaHostApiIndex member, but PortAudio
    // unfortunately provides no good way to associate this with a persistent,
    // unique identifier for the API. So, build a QHash to do that and pass
    // it to the SoundDevicePortAudio constructor.
    QHash<PaHostApiIndex, PaHostApiTypeId> paApiIndexToTypeId;
    for (PaHostApiIndex i = 0; i < Pa_GetHostApiCount(); i++) {
        const PaHostApiInfo* api = Pa_GetHostApiInfo(i);
        if (api && QString(api->name) != "skeleton implementation") {
            paApiIndexToTypeId.insert(i, api->type);
        }
    }

    const PaDeviceInfo* deviceInfo;
    for (int i = 0; i < iNumDevices; i++) {
        deviceInfo = Pa_GetDeviceInfo(i);
        qDebug() << "Pa_GetDeviceInfo on" << i << deviceInfo;
        if (!deviceInfo) {
            continue;
        }
        /* deviceInfo fields for quick reference:
            int     structVersion
            const char *    name
            PaHostApiIndex  hostApi
            int     maxInputChannels
            int     maxOutputChannels
            PaTime  defaultLowInputLatency
            PaTime  defaultLowOutputLatency
            PaTime  defaultHighInputLatency
            PaTime  defaultHighOutputLatency
            double  defaultSampleRate
         */
        const auto deviceTypeId = paApiIndexToTypeId.value(deviceInfo->hostApi);
        auto currentDevice = QSharedPointer<SoundDevicePortAudio>::create(
                m_pConfig, m_pSoundManager, deviceInfo, deviceTypeId, i);
        m_devices.push_back(currentDevice);
        if (Pa_GetHostApiInfo(deviceInfo->hostApi)->name == SoundManagerConfig::kAPIJack) {
            m_jackSampleRate = static_cast<mixxx::audio::SampleRate::value_t>(
                    deviceInfo->defaultSampleRate);
        }
    }

    m_apis.clear();
    for (PaHostApiIndex i = 0; i < Pa_GetHostApiCount(); i++) {
        const PaHostApiInfo* api = Pa_GetHostApiInfo(i);
        if (api && std::strcmp(api->name, "skeleton implementation")) {
            m_apis.push_back(api->name);
        }
    }
}

std::vector<SoundDevicePointer> PortAudioEnumerator::queryDevices() const {
    if (!m_initialized) {
        return {};
    }

    std::vector<SoundDevicePointer> devices;
    for (const auto& device : m_devices) {
        devices.push_back(device);
    }

    return devices;
}

void PortAudioEnumerator::setJACKName() const {
#ifdef Q_OS_LINUX
    typedef PaError (*SetJackClientName)(const char* name);
    QLibrary portaudio("libportaudio.so.2");
    if (portaudio.load()) {
        SetJackClientName func(
                reinterpret_cast<SetJackClientName>(
                        portaudio.resolve("PaJack_SetClientName")));
        if (func) {
            // PortAudio does not make a copy of the string we provide it so we
            // need to make sure it will last forever so we intentionally leak
            // this string.
            char* jackNameCopy = strdup(VersionStore::applicationName().toLocal8Bit().constData());
            if (!func(jackNameCopy)) {
                qDebug() << "JACK client name set";
            }
        } else {
            qWarning() << "failed to resolve JACK name method";
        }
    } else {
        qWarning() << "failed to load portaudio for JACK rename";
    }
#endif
}

void PortAudioEnumerator::deinitialize() {
    if (!m_initialized) {
        return;
    }

    m_devices.clear();

    PaError err = Pa_Terminate();
    if (err == paNoError) {
        m_initialized = false;
#ifdef Q_OS_ANDROID
        // PortAudio drops its Oboe device table on terminate, so the next
        // initialize() must re-register every device from scratch. Reset only
        // on success: if terminate failed, the old table is still alive and
        // re-registering would create duplicates.
        m_oboeRegistered = false;
#endif
    }
}

QList<mixxx::audio::SampleRate> PortAudioEnumerator::getSampleRates(bool jackSampleRate) const {
    if (jackSampleRate and m_jackSampleRate.isValid()) {
        return {m_jackSampleRate};
    }

    return {};
}
