#include "controllers/midi/androidmidienumerator.h"

#include <QJniObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QtCore/qcoreapplication_platform.h>

#include "controllers/midi/androidmidicontroller.h"
#include "moc_androidmidienumerator.cpp"

namespace {
constexpr const char* kBridgeClass = "org/mixxx/MidiBridge";
} // namespace

AndroidMidiEnumerator::AndroidMidiEnumerator() {
    const QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (!context.isValid()) {
        qWarning() << "AndroidMidiEnumerator: no application context, MIDI will be unavailable";
        return;
    }
    QJniObject::callStaticMethod<void>(kBridgeClass,
            "init",
            "(Landroid/content/Context;)V",
            context);
}

AndroidMidiEnumerator::~AndroidMidiEnumerator() {
    qDebug() << "Deleting Android MIDI devices...";
    qDeleteAll(m_devices);
    m_devices.clear();
    QJniObject::callStaticMethod<void>(kBridgeClass, "closeAll", "()V");
}

QList<Controller*> AndroidMidiEnumerator::queryDevices() {
    qDebug() << "Scanning Android MIDI devices:";

    qDeleteAll(m_devices);
    m_devices.clear();

    const QJniObject json = QJniObject::callStaticObjectMethod(kBridgeClass,
            "listDevices",
            "()Ljava/lang/String;");
    if (!json.isValid()) {
        qWarning() << "AndroidMidiEnumerator: MidiBridge.listDevices() failed";
        return m_devices;
    }

    QJsonParseError parseError = {};
    const QJsonDocument doc = QJsonDocument::fromJson(json.toString().toUtf8(), &parseError);
    if (parseError.error != QJsonParseError::NoError || !doc.isArray()) {
        qWarning() << "AndroidMidiEnumerator: could not parse device list:"
                   << parseError.errorString();
        return m_devices;
    }

    const QJsonArray devices = doc.array();
    for (const QJsonValue& value : devices) {
        const QJsonObject o = value.toObject();
        const int deviceId = o.value(QStringLiteral("id")).toInt(-1);
        const int inputPorts = o.value(QStringLiteral("inputPorts")).toInt(0);
        const int outputPorts = o.value(QStringLiteral("outputPorts")).toInt(0);
        if (deviceId < 0) {
            continue;
        }
        if (inputPorts <= 0 && outputPorts <= 0) {
            continue;
        }

        QString name = o.value(QStringLiteral("name")).toString().trimmed();
        if (name.isEmpty()) {
            name = QStringLiteral("MIDI device %1").arg(deviceId);
        }
        const QString manufacturer = o.value(QStringLiteral("manufacturer")).toString();
        const QString product = o.value(QStringLiteral("product")).toString();
        const QString serialNumber = o.value(QStringLiteral("serial")).toString();
        const int androidType = o.value(QStringLiteral("type")).toInt(0);

        qDebug() << " Found Android MIDI device"
                 << "#" << deviceId << name
                 << "type" << androidType
                 << "in" << inputPorts
                 << "out" << outputPorts;

        m_devices.push_back(new AndroidMidiController(deviceId,
                name,
                manufacturer,
                product,
                serialNumber,
                androidType,
                inputPorts,
                outputPorts));
    }
    return m_devices;
}
