#include "StreamController.h"
#include "ApiClient.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>

StreamController::StreamController(QObject *parent) : QObject(parent)
{
}

void StreamController::startStream(const QString& cameraId, const QString& cameraPath, int fps, int width, int height)
{
    QJsonObject requestData;
    requestData["cam"] = cameraId;
    requestData["cam_path"] = cameraPath;
    requestData["fps"] = fps;
    requestData["width"] = width;
    requestData["height"] = height;

    QJsonDocument doc(requestData);
    QByteArray data = doc.toJson();

    QNetworkReply* reply = ApiClient::instance()->post("/stream/config/start", data);
    connect(reply, &QNetworkReply::finished, this, &StreamController::onStreamStarted);

    // Optimistically set the current camera ID
    setCurrentCameraId(cameraId);
}

void StreamController::stopStream()
{
    QNetworkReply* reply = ApiClient::instance()->put("/stream/config/stop", QByteArray());
    connect(reply, &QNetworkReply::finished, this, &StreamController::onStreamStopped);
}

void StreamController::onStreamStarted()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        QString streamUrlString = QString::fromUtf8(data).remove('"');

        setStreamUrl(QUrl(streamUrlString));
        setStreaming(true);
    } else {
        emit error("Failed to start stream: " + reply->errorString());
        // If starting failed, reset the state
        setCurrentCameraId("");
        setStreaming(false);
    }
    reply->deleteLater();
}

void StreamController::onStreamStopped()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        setStreamUrl(QUrl());
        setStreaming(false);
        setCurrentCameraId("");
    } else {
        emit error("Failed to stop stream: " + reply->errorString());
    }
    reply->deleteLater();
}

void StreamController::setStreamUrl(const QUrl& url)
{
    if (m_streamUrl != url) {
        m_streamUrl = url;
        emit streamUrlChanged();
    }
}

void StreamController::setStreaming(bool streaming)
{
    if (m_streaming != streaming) {
        m_streaming = streaming;
        emit streamingChanged();
    }
}

void StreamController::setCurrentCameraId(const QString& cameraId)
{
    if (m_currentCameraId != cameraId) {
        m_currentCameraId = cameraId;
        emit currentCameraIdChanged();
    }
}
