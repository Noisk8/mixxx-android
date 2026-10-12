#include "controllers/midi/androidmidicontroller.h"

#include <QJniArray>
#include <QJniObject>

#include "controllers/midi/midiutils.h"
#include "moc_androidmidicontroller.cpp"
#include "util/time.h"

namespace {
constexpr const char* kBridgeClass = "org/mixxx/MidiBridge";
// Maximum number of message chunks to process per poll() call to avoid
// starving the ControllerManager thread when a device floods us.
constexpr int kMaxChunksPerPoll = 256;

} // anonymous namespace

AndroidMidiController::AndroidMidiController(int deviceId,
        const QString& name,
        const QString& manufacturer,
        const QString& product,
        const QString& serialNumber,
        int androidType,
        int inputPorts,
        int outputPorts)
        : MidiController(name),
          m_deviceId(deviceId),
          m_manufacturer(manufacturer),
          m_product(product),
          m_serialNumber(serialNumber),
          m_androidType(androidType),
          m_inputPorts(inputPorts),
          m_outputPorts(outputPorts) {
    // We are an input device for Mixxx if we can receive data from the
    // controller (device output ports) and an output device if we can send
    // data to it (device input ports).
    setInputDevice(m_outputPorts > 0);
    setOutputDevice(m_inputPorts > 0);
}

AndroidMidiController::~AndroidMidiController() {
    if (isOpen()) {
        close();
    }
}

void AndroidMidiController::rebindDevice(int deviceId) {
    if (m_deviceId == deviceId) { return; }
    if (isOpen()) { close(); }
    m_parser.reset();
    m_deviceId = deviceId;
}

int AndroidMidiController::open(const QString& resourcePath) {
    if (m_deviceId < 0) { return -2; }
    if (isOpen()) {
        qCWarning(m_logBase) << "Android MIDI device" << getName() << "already open";
        return -1;
    }

    m_parser.reset();

    const bool ok = QJniObject::callStaticMethod<jboolean>(kBridgeClass,
            "open",
            "(IZZ)Z",
            m_deviceId,
            static_cast<jboolean>(m_inputPorts > 0),
            static_cast<jboolean>(m_outputPorts > 0));
    if (!ok) {
        qCWarning(m_logBase) << "Could not open Android MIDI device" << getName();
        return -2;
    }

    qCInfo(m_logBase) << "AndroidMidiController: Opening" << getName()
                      << "id" << m_deviceId;
    startEngine();
    applyMapping(resourcePath);
    setOpen(true);
    return 0;
}

int AndroidMidiController::close() {
    if (!isOpen()) {
        qCWarning(m_logBase) << "Android MIDI device" << getName() << "already closed";
        return -1;
    }

    stopEngine();
    MidiController::close();

    QJniObject::callStaticMethod<void>(kBridgeClass, "close", "(I)V", m_deviceId);

    setOpen(false);
    return 0;
}

bool AndroidMidiController::poll() {
    if (!isOpen()) {
        return false;
    }

    bool handled = false;
    for (int i = 0; i < kMaxChunksPerPoll; ++i) {
        QJniArray<jlong> tsArray{0};
        QJniObject chunk = QJniObject::callStaticMethod<QJniObject>(kBridgeClass,
                "receive",
                "(I[J)[B",
                m_deviceId,
                tsArray);
        if (!chunk.isValid()) {
            break;
        }
        QJniArray<jbyte> bytes(chunk);
        const qsizetype size = bytes.size();
        if (size <= 0) {
            m_parser.reset();
            handled = true;
            continue;
        }
        // MidiReceiver timestamps use an arbitrary nanosecond clock. Use our
        // own monotonic clock at arrival time instead so all messages share a
        // consistent time base, like PortMidi does.
        const mixxx::Duration now = mixxx::Time::elapsed();
        for (qsizetype j = 0; j < size; ++j) {
            processByte(static_cast<unsigned char>(bytes.at(j)), now);
        }
        handled = true;
    }
    return handled;
}

void AndroidMidiController::processByte(unsigned char byte, const mixxx::Duration& timestamp) {
    const auto message = m_parser.processByte(byte);
    switch (message.type) {
    case mixxx::MidiStreamParser::MessageType::Short:
        receivedShortMessage(message.status, message.data1, message.data2, timestamp);
        break;
    case mixxx::MidiStreamParser::MessageType::SysEx:
        receive(QByteArray::fromRawData(
                        reinterpret_cast<const char*>(message.sysexData),
                        static_cast<int>(message.sysexSize)),
                timestamp);
        break;
    case mixxx::MidiStreamParser::MessageType::None:
        break;
    }
}

void AndroidMidiController::sendShortMsg(unsigned char status,
        unsigned char byte1,
        unsigned char byte2) {
    const int dataLength = mixxx::MidiStreamParser::shortMessageDataLength(status);
    if (dataLength < 0) {
        qCWarning(m_logOutput) << "Refusing invalid or SysEx status via sendShortMsg";
        return;
    }
    QByteArray bytes;
    bytes.reserve(1 + dataLength);
    bytes.append(static_cast<char>(status));
    if (dataLength >= 1) {
        bytes.append(static_cast<char>(byte1));
    }
    if (dataLength >= 2) {
        bytes.append(static_cast<char>(byte2));
    }
    if (!sendBytes(bytes)) {
        qCWarning(m_logOutput) << "Error sending short message"
                               << MidiUtils::formatMidiOpCode(getName(),
                                           status,
                                           byte1,
                                           byte2,
                                           MidiUtils::channelFromStatus(status),
                                           MidiUtils::opCodeFromStatus(status));
    } else {
        qCDebug(m_logOutput) << QStringLiteral("outgoing: ")
                             << MidiUtils::formatMidiOpCode(getName(),
                                         status,
                                         byte1,
                                         byte2,
                                         MidiUtils::channelFromStatus(status),
                                         MidiUtils::opCodeFromStatus(status));
    }
}

bool AndroidMidiController::sendBytes(const QByteArray& data) {
    if (data.isEmpty()) {
        return false;
    }
    const QJniArray<jbyte> bytes(data);
    const jboolean ok = QJniObject::callStaticMethod<jboolean>(kBridgeClass,
            "send",
            "(I[B)Z",
            m_deviceId,
            bytes);
    if (!ok) {
        qCWarning(m_logOutput) << "Error sending message to Android MIDI device"
                               << getName();
        return false;
    }
    return true;
}
