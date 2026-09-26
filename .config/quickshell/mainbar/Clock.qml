import QtQuick
import qs as Root

Rectangle {
    id: clockContainer
    width: 44
    height: 70
    color: Root.Colors.bgMain
    radius: 8

    Column {
        anchors.centerIn: parent
        spacing: 8

        Text {
            id: txtTime
            anchors.horizontalCenter: parent.horizontalCenter
            color: Root.Colors.mainIcon
            font.pixelSize: 12
            font.bold: true
            text: Qt.formatDateTime(new Date(), "hh:mm")
        }

        Text {
            id: txtDate
            anchors.horizontalCenter: parent.horizontalCenter
            color: Root.Colors.whiteText
            font.pixelSize: 9
            font.bold: false
            text: Qt.formatDateTime(new Date(), "dd/MM")
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var currentDate = new Date()
            txtTime.text = Qt.formatDateTime(currentDate, "hh:mm")
            txtDate.text = Qt.formatDateTime(currentDate, "dd/MM")
        }
    }
}
