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

/// Number of data bytes that follow the given status byte, or -1 if the
/// status byte is not a valid short message status (SysEx).
int shortMessageDataLength(unsigned char status) {
    if (status >= 0xF8) {
        // System realtime messages carry no data bytes
        return 0;
    }
    switch (status) {
    case 0xF1: // MTC quarter frame
    case 0xF3: // Song select
        return 1;
    case 0xF2: // Song position
        return 2;
    case 0xF4: // Undefined (reserved)
    case 0xF5: // Undefined (reserved)
    case 0xF6: // Tune request
    case 0xF7: // EOX
        return 0;
    case 0xF0: // SysEx start -- not a short message
        return -1;
    default:
        break;
    }
    const unsigned char opCode = status & 0xF0;
    if (opCode == 0xC0 || opCode == 0xD0) {
        // Program change and channel pressure carry one data byte
        return 1;
    }
    // All other channel voice/mode messages carry two data bytes
    return 2;
}
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
          m_outputPorts(outputPorts),
          m_status(0),
          m_dataIndex(0),
          m_dataLength(0),
          m_bInSysex(false),
          m_cReceiveMsgIndex(0) {
    m_data[0] = 0;
    m_data[1] = 0;
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

int AndroidMidiController::open(const QString& resourcePath) {
    if (isOpen()) {
        qCWarning(m_logBase) << "Android MIDI device" << getName() << "already open";
        return -1;
    }

    m_status = 0;
    m_dataIndex = 0;
    m_dataLength = 0;
    m_bInSysex = false;
    m_cReceiveMsgIndex = 0;

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
            break;
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
    // System realtime messages (0xF8..0xFF) may appear anywhere, even in the
    // middle of a SysEx message or between the data bytes of a short message.
    if (byte >= 0xF8) {
        receivedShortMessage(byte, 0, 0, timestamp);
        return;
    }

    if (m_bInSysex) {
        if (byte == MidiUtils::opCodeValue(MidiOpCode::EndOfExclusive)) {
            m_bInSysex = false;
            const char* buffer = reinterpret_cast<const char*>(m_cReceiveMsg);
            receive(QByteArray::fromRawData(buffer, m_cReceiveMsgIndex), timestamp);
            m_cReceiveMsgIndex = 0;
            return;
        }
        if (byte >= 0x80) {
            // A status byte other than EOX aborts the SysEx message
            m_bInSysex = false;
            m_cReceiveMsgIndex = 0;
            m_status = 0;
            m_dataIndex = 0;
            m_dataLength = 0;
            qCWarning(m_logInput) << "Buggy MIDI device: SysEx interrupted!";
            // Fall through to process the status byte as a new message
        } else {
            if (m_cReceiveMsgIndex < MIXXX_ANDROID_MIDI_SYSEX_BUFFER_LEN) {
                m_cReceiveMsg[m_cReceiveMsgIndex++] = byte;
            }
            return;
        }
    }

    if (byte >= 0x80) {
        if (byte == MidiUtils::opCodeValue(MidiOpCode::SystemExclusive)) {
            m_bInSysex = true;
            m_cReceiveMsgIndex = 0;
            m_status = 0;
            m_dataIndex = 0;
            m_dataLength = 0;
            return;
        }
        const int dataLength = shortMessageDataLength(byte);
        if (dataLength < 0) {
            return;
        }
        // New status byte replaces any partially received message and
        // establishes running status for channel messages.
        m_status = byte;
        m_dataLength = dataLength;
        m_dataIndex = 0;
        if (dataLength == 0) {
            // System common message without data bytes
            if (byte == MidiUtils::opCodeValue(MidiOpCode::TuneRequest)) {
                receivedShortMessage(byte, 0, 0, timestamp);
            }
            // System common messages (and undefined/reserved messages 0xF4,
            // 0xF5 and EOX outside of SysEx) clear the running status.
            m_status = 0;
        }
        return;
    }

    // Data byte
    if (m_status == 0 || m_dataLength <= 0) {
        // Running status without a preceding status byte -- ignore
        return;
    }
    m_data[m_dataIndex++] = byte;
    if (m_dataIndex >= m_dataLength) {
        receivedShortMessage(m_status,
                m_data[0],
                m_dataLength > 1 ? m_data[1] : 0,
                timestamp);
        m_dataIndex = 0;
        if (m_status >= 0xF0) {
            // System common messages do not establish running status
            m_status = 0;
        }
        // else: keep m_status for running status of channel messages
    }
}

void AndroidMidiController::sendShortMsg(unsigned char status,
        unsigned char byte1,
        unsigned char byte2) {
    const int dataLength = shortMessageDataLength(status);
    if (dataLength < 0) {
        qCWarning(m_logOutput) << "Refusing to send SysEx via sendShortMsg";
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
