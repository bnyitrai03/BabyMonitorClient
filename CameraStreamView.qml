import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

ColumnLayout {
    id: root
    spacing: 10
    //padding: 10

    property var selectedCamera: cameraComboStream.currentIndex !== -1 ? cameraController.cameras[cameraComboStream.currentIndex] : null
    property var selectedFormat: selectedCamera ? formatCombo.currentText : ""
    property var selectedResolution: selectedFormat ? resolutionCombo.currentText : ""

    GridLayout {
        columns: 2

        Label { text: "Camera:" }
        ComboBox { id: cameraComboStream; Layout.fillWidth: true; model: cameraController.cameras; textRole: "id" }

        Label { text: "Format:" }
        ComboBox { id: formatCombo; Layout.fillWidth: true; model: selectedCamera ? Object.keys(selectedCamera.formats) : [] }

        Label { text: "Resolution:" }
        ComboBox { id: resolutionCombo; Layout.fillWidth: true; model: selectedFormat ? Object.keys(selectedCamera.formats[selectedFormat]) : [] }

        Label { text: "FPS:" }
        ComboBox { id: fpsCombo; Layout.fillWidth: true; model: selectedResolution ? selectedCamera.formats[selectedFormat][selectedResolution] : [] }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        Button {
            text: "Start Stream"
            enabled: selectedCamera
            onClicked: {
                var resParts = selectedResolution.split('x');
                var width = parseInt(resParts[0]);
                var height = parseInt(resParts[1]);
                streamingController.startStream(selectedCamera.id, selectedCamera.name, fpsCombo.currentText, width, height)
            }
        }
        Button {
            text: "Stop Stream"
            onClicked: streamingController.stopStream()
        }
    }

    MediaPlayer {
        id: mediaPlayer
        source: streamingController.streamUrl
        audioOutput: AudioOutput {} // Muted audio output
    }

    VideoOutput {
        Layout.fillWidth: true
        Layout.fillHeight: true
        //source: mediaPlayer
    }

    Component.onCompleted: {
        mediaPlayer.play()
    }
    // onSourceChanged: {
    //     mediaPlayer.play()
    // }
}
