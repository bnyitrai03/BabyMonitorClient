import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BabyMonitor 1.0

ApplicationWindow {
    id: window
    width: 1280
    height: 720
    visible: true
    title: "Baby Monitor Client"

    TabBar {
        id: bar
        width: parent.width

        TabButton {
            text: qsTr("Stream and Control")
        }

        TabButton {
            text: qsTr("Sensor Data")
        }
    }

    StackLayout {
        width: parent.width
        currentIndex: bar.currentIndex
        anchors.top: bar.bottom
        anchors.bottom: parent.bottom
        Item {
            id: streamTab
            CameraStreamView{
                anchors.fill: parent
            }
        }

        Item {
            id: sensorTab
            SensorView {
                anchors.fill: parent
            }
        }
    }

}
