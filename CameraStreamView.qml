import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtWebEngine
import BabyMonitor 1.0

Rectangle {
    id: root
    color: "#f0f0f0"

    property bool readyToStream: resolutionComboBox.currentIndex > -1
                                 && fpsComboBox.currentIndex > -1

    // --- Main Layout ---
    RowLayout {
        anchors.fill: parent
        spacing: 10
        anchors.margins: 10

        // --- Left Panel: Controls ---
        Frame {
            id: controlPanel
            Layout.preferredWidth: 350
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 5

                // --- Device Selector Section ---
                Label {
                    text: "Device Selection"
                    font.bold: true
                }
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    columnSpacing: 10
                    Label {
                        text: "Device:"
                    }
                    ComboBox {
                        id: deviceSelector
                        Layout.fillWidth: true
                        model: ["ncwl-a01-e03-1", "rpicm5"]
                        // Start with no item selected
                        currentIndex: -1
                        displayText: currentIndex > -1 ? currentText : "Please select a device..."

                        onCurrentTextChanged: {
                            ApiClient.setUrlandCert(currentText)
                            cameraController.refreshCameras()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#cccccc"
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                }

                ColumnLayout {
                    id: configurationGroup
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 5
                    enabled: deviceSelector.currentIndex > -1

                    // --- Top Half: Camera Selection ---
                    Label {
                        text: "Camera Configuration"
                        font.bold: true
                    }

                    // --- Camera Controls Section ---
                    CameraControls {
                        Layout.fillWidth: true
                    }

                    // Spacer to push the rest of the controls to the bottom half
                    Item {
                        Layout.fillHeight: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#cccccc"
                    }

                    // --- Bottom Half: Stream Settings ---
                    Label {
                        text: "Stream Configuration"
                        font.bold: true
                    }

                    GridLayout {
                        columns: 2
                        columnSpacing: 10
                        rowSpacing: 5

                        Label {
                            text: "Camera eye:"
                        }
                        ComboBox {
                            id: cameraeyeComboBox
                            Layout.fillWidth: true
                            enabled: !streamController.streaming
                            textRole: "text"
                            model: [{
                                    "value": qsTr("Left"),
                                    "text": qsTr("Left")
                                }, {
                                    "value": qsTr("Right"),
                                    "text": qsTr("Right")
                                }]
                        }

                        Label {
                            text: "Resolution:"
                        }
                        ComboBox {
                            id: resolutionComboBox
                            Layout.fillWidth: true
                            enabled: !streamController.streaming
                            model: []
                            onCurrentIndexChanged: {
                                fpsComboBox.model = []
                                if (currentIndex > -1
                                        && cameraController.activeCamera !== null)
                                    fpsComboBox.model = cameraController.getFpsForResolution(
                                                cameraController.activeCamera.id,
                                                currentText)
                            }
                        }

                        Label {
                            text: "FPS:"
                        }
                        ComboBox {
                            id: fpsComboBox
                            Layout.fillWidth: true
                            enabled: !streamController.streaming
                            model: []
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10
                        Layout.bottomMargin: 5

                        Button {
                            text: "Start Stream"
                            enabled: !streamController.streaming
                                     && readyToStream
                            onClicked: {
                                const resolutionParts = resolutionComboBox.currentText.split('x')
                                streamController.startStream(
                                            cameraController.activeCamera.id,
                                            cameraController.activeCamera.path,
                                            cameraeyeComboBox.currentText,
                                            parseInt(fpsComboBox.currentText),
                                            parseInt(resolutionParts[0]),
                                            parseInt(resolutionParts[1]))
                            }
                        }

                        Button {
                            text: "Stop Stream"
                            enabled: streamController.streaming
                            onClicked: streamController.stopStream()
                        }
                    }
                }
            }
        }

        StreamView {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    // --- Global Error Handling ---
    Connections {
        target: cameraController
        function onError(message) {
            errorDialog.title = "Camera Error"
            errorDialog.text = message
            errorDialog.open()
        }
    }
    Connections {
        target: streamController
        function onError(message) {
            errorDialog.title = "Stream Error"
            errorDialog.text = message
            errorDialog.open()
        }
    }
    Connections {
        target: ApiClient
        function onError(message) {
            errorDialog.title = "Connection Error"
            errorDialog.text = message
            errorDialog.open()
        }
    }
    MessageDialog {
        id: errorDialog
        buttons: Dialog.Ok
        text: parent.text
    }
}
