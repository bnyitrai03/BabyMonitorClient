// CameraSettingsMenu.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BabyMonitor 1.0

Drawer {
    id: root
    width: 300
    height: parent ? parent.height : 0
    edge: Qt.Right // Slides in from the right edge
    modal: true // Dims the background when open
    interactive: true

    // The camera object whose settings we are displaying.
    // This will be set by the parent view.
    property var activeCamera: null

    // Signal to notify the parent when an update happens
    signal controlsUpdated

    background: Frame { } // Gives it a proper background and border

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 15

        // --- Menu Header ---
        Label {
            Layout.fillWidth: true
            text: activeCamera ? activeCamera.name + " Settings" : "Camera Settings"
            font.pixelSize: 20
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        // --- Controls Area ---
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            visible: activeCamera // Only show if a camera is selected

            ColumnLayout {
                width: parent.width
                spacing: 12

                Repeater {
                    id: controlsRepeater
                    // The model is the list of control names (keys) from the camera's 'controls' map
                    model: activeCamera ? Object.keys(activeCamera.controls) : []

                    delegate: ColumnLayout {
                        width: parent.width
                        spacing: 4

                        // Label for the control (e.g., "Brightness")
                        Label {
                            text: modelData.charAt(0).toUpperCase() + modelData.slice(1) // Capitalize first letter
                            font.bold: true
                        }

                        // Slider to adjust the value
                        Slider {
                            id: controlSlider
                            width: parent.width
                            from: 0  // TODO: Ideally, API should provide min/max/step for each control
                            to: 255
                            value: activeCamera.controls[modelData] // Bind to the current value
                        }

                        // Label to show the current value
                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: controlSlider.value.toFixed(0)
                            font.italic: true
                            color: "#555"
                        }
                    }
                }
            }
        }

        // --- Action Buttons ---
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Button {
                text: "Reset"
                enabled: activeCamera && controlsRepeater.count > 0
                onClicked: {
                    CameraController.resetCameraControls(activeCamera.id)
                    root.controlsUpdated()
                }
            }
            Button {
                text: "Close"
                highlighted: true
                onClicked: root.close()
            }
        }
    }
}
