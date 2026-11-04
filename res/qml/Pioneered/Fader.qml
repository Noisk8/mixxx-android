import QtQuick
import Mixxx 1.0 as Mixxx
import ".." as Skin

Skin.Fader {
    id: root

    required property string group
    required property string key

    bar.color: "#ff8b18"
    bar.width: 4
    value: control.parameter

    onMoved: value => control.parameter = value

    Mixxx.ControlProxy {
        id: control

        group: root.group
        key: root.key
    }
}
