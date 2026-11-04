pragma ComponentBehavior: Bound

import QtQuick
import Mixxx 1.0 as Mixxx

Item {
    id: root

    required property var surface

    Repeater {
        model: [
            {
                key: "mobile_library_toggle",
                tab: 1
            },
            {
                key: "mobile_fx_toggle",
                tab: 3
            }
        ]

        Item {
            id: toggle

            property bool created: false
            required property var modelData

            Mixxx.SkinControlCreator {
                group: "[Skin]"
                key: toggle.modelData.key

                Component.onCompleted: toggle.created = true
            }
            Mixxx.ControlProxy {
                group: "[Skin]"
                key: toggle.created ? toggle.modelData.key : ""

                onValueChanged: value => {
                    if (value > 0) {
                        root.surface.currentTab = root.surface.currentTab === toggle.modelData.tab ? 0 : toggle.modelData.tab;
                    }
                }
            }
        }
    }
    Repeater {
        model: 2

        Item {
            id: loader

            property bool created: false
            readonly property string group: `[Channel${index + 1}]`
            required property int index

            Mixxx.SkinControlCreator {
                group: "[Skin]"
                key: `mobile_loader_deck${loader.index + 1}`

                Component.onCompleted: loader.created = true
            }
            Mixxx.ControlProxy {
                group: "[Skin]"
                key: loader.created ? `mobile_loader_deck${loader.index + 1}` : ""

                onValueChanged: value => {
                    if (value > 0)
                        root.surface.openQuickLoad(loader.group);
                }
            }
            Mixxx.ControlProxy {
                group: loader.group
                key: "LoadSelectedTrack"

                onValueChanged: value => {
                    if (value > 0 && root.surface.currentTab !== 1) {
                        Qt.callLater(root.surface.openQuickLoad, loader.group);
                    }
                }
            }
        }
    }
}
