import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".." as Skin

Skin.ControlButton {
    id: root

    contentItem: ColumnLayout {
        spacing: 0

        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 20
            Layout.preferredWidth: 20
            fillMode: Image.PreserveAspectFit
            source: root.icon.source
        }
        Label {
            Layout.fillWidth: true
            color: root.highlight ? root.activeColor : "#cccccc"
            elide: Text.ElideRight
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
            text: root.text
        }
    }
}
