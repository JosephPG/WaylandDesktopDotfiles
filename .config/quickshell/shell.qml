import QtQuick
import Quickshell
import "./mainbar"

ShellRoot {
    PanelWindow {
        id: sideBar
        anchors {
            top: true
            bottom: true
            left: true
        }
        color: "transparent"
        implicitWidth: 40
        height: screen.height

        // ==========================================
        // SECCIÓN SUPERIOR
        // ==========================================
        Clock {
            id: clockContainer
            anchors {
                top: parent.top
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
        }
        SystemInfo {
            id: systeminfoContainer
            anchors {
                top: clockContainer.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
        }

        // ==========================================
        // SECCIÓN CENTRAL (PEAR / MÚSICA DE YOUTUBE)
        // ==========================================
        Pear {
            id: pearContainer
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
        }

        // ==========================================
        // SECCIÓN INFERIOR
        // ==========================================
        Bluetooth {
            anchors {
                bottom: networkContainer.top
                bottomMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
        }
        Network {
            id: networkContainer
            anchors {
                bottom: workspacesContainer.top
                bottomMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
        }
        Workspaces {
            id: workspacesContainer
            anchors {
                bottom: parent.bottom
                bottomMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
