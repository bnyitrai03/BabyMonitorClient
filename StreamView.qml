import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtWebEngine
import BabyMonitor 1.0

Frame {
    StackLayout {
        anchors.fill: parent
        currentIndex: streamController.streaming
                      && streamController.streamUrl.toString() !== "" ? 1 : 0
        
        // --- Not streaming / connecting ---
        Rectangle {
            color: "black"
            Label {
                anchors.centerIn: parent
                color: "white"
                text: streamController.streaming ? "Connecting..." : "Stream not active."
                horizontalAlignment: Text.AlignHCenter
            }
        }
        
        WebEngineView {
            id: streamView
            anchors.fill: parent
            url: streamController.streamUrl
            
            settings {
                accelerated2dCanvasEnabled: true
                webGLEnabled: true
                
                javascriptEnabled: false
                pluginsEnabled: false
                autoLoadImages: true
                touchIconsEnabled: false
                focusOnNavigationEnabled: false
            }
            
            onCertificateError: function (error) {
                console.log("Certificate error:", error.description)
                console.log("Error URL:", error.url)
                // Accept the certificate error for self-signed certificates
                error.acceptCertificate()
            }
        }
    }
}
