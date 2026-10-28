import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12

Skin.Fader {
    id: root

    required property string group
    required property string key

    value: control.parameter

    onMoved: function (value) {
        control.parameter = value;
    }

    Mixxx.ControlProxy {
        id: control

        group: root.group
        key: root.key
    }

    // Touch-optimized direct dragging and tapping for mobile screens
    MouseArea {
        id: touchArea
        anchors.fill: parent
        preventStealing: true

        function updateFromTouch(mouse) {
            var pos = 0.5;
            if (root.vertical) {
                pos = 1.0 - Math.max(0.0, Math.min(1.0, mouse.y / height));
            } else {
                pos = Math.max(0.0, Math.min(1.0, mouse.x / width));
            }
            control.parameter = pos;
        }

        onPressed: mouse => updateFromTouch(mouse)
        onPositionChanged: mouse => {
            if (pressed) {
                updateFromTouch(mouse);
            }
        }
        onDoubleClicked: control.reset()
    }
}
