import QtQuick
import Quickshell.Hyprland
import qs as Root

Rectangle {
    id: workspaceContainer
    width: 44
    height: 160
    color: Root.Colors.bgMain
    radius: 12

    Column {
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: [1, 2, 3, 4, 5, 6]

            delegate: Item {
                width: 20
                height: 20

                readonly property int wsId: modelData
                readonly property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId

                Rectangle {
                    id: dot
                    anchors.centerIn: parent
                    width: isActive ? 12 : 8
                    height: isActive ? 12 : 8
                    radius: width / 2
                    color: isActive ? Root.Colors.mainIcon : Root.Colors.grayText

                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on width { NumberAnimation { duration: 200 } }
                    Behavior on height { NumberAnimation { duration: 200 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Hyprland.dispatch("workspace " + wsId)
                    }
                }
            }
        }
    }
}
