#pragma once

#include "controllers/midi/midicontroller.h"

// Length of the reassembly buffer for incoming SysEx messages in bytes
#define MIXXX_ANDROID_MIDI_SYSEX_BUFFER_LEN 1024

/// Android (android.media.midi) based implementation of MidiController
///
/// The actual I/O happens in the org.mixxx.MidiBridge Java class; this class
/// polls the bridge for raw MIDI bytes and reassembles them into short
/// messages (with running status support) and SysEx messages.
class AndroidMidiController : public MidiController {
    Q_OBJECT
  public:
    AndroidMidiController(int deviceId,
            const QString& name,
            const QString& manufacturer,
            const QString& product,
            const QString& serialNumber,
            int androidType,
            int inputPorts,
            int outputPorts);
    ~AndroidMidiController() override;

    PhysicalTransportProtocol getPhysicalTransportProtocol() const override {
        // android.media.midi.MidiDeviceInfo types:
        // TYPE_USB = 1, TYPE_VIRTUAL = 2, TYPE_BLUETOOTH = 3
        if (m_androidType == 1) {
            return PhysicalTransportProtocol::USB;
        }
        if (m_androidType == 3) {
            return PhysicalTransportProtocol::BlueTooth;
        }
        return PhysicalTransportProtocol::UNKNOWN;
    }

    QString getVendorString() const override {
        return m_manufacturer;
    }
    QString getProductString() const override {
        return m_product;
    }
    std::optional<uint16_t> getVendorId() const override {
        return std::nullopt;
    }
    std::optional<uint16_t> getProductId() const override {
        return std::nullopt;
    }
    QString getSerialNumber() const override {
        return m_serialNumber;
    }
    std::optional<uint8_t> getUsbInterfaceNumber() const override {
        return std::nullopt;
    }

  private slots:
    bool poll() override;

  protected:
    void sendShortMsg(unsigned char status,
            unsigned char byte1,
            unsigned char byte2) override;

  private:
    int open(const QString& resourcePath) override;
    int close() override;

    // The sysex data must already contain the start byte 0xf0 and the end byte
    // 0xf7.
    bool sendBytes(const QByteArray& data) override;

    bool isPolling() const override {
        return true;
    }

    void processByte(unsigned char byte, const mixxx::Duration& timestamp);

    const int m_deviceId;
    const QString m_manufacturer;
    const QString m_product;
    const QString m_serialNumber;
    const int m_androidType;
    // Number of device ports we can send to (device input ports)
    const int m_inputPorts;
    // Number of device ports we can receive from (device output ports)
    const int m_outputPorts;

    // Streaming MIDI parser state
    unsigned char m_status;
    unsigned char m_data[2];
    int m_dataIndex;
    int m_dataLength;
    bool m_bInSysex;
    unsigned char m_cReceiveMsg[MIXXX_ANDROID_MIDI_SYSEX_BUFFER_LEN];
    int m_cReceiveMsgIndex;
};
