#include "StreamController.h"
#include "ApiClient.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>

StreamController::StreamController(QObject *parent) : QObject(parent)
{
}

void StreamController::startStream(const QString& cameraId, const QString& path, const QString& eye, int fps, int width, int height)
{
    QJsonObject requestData;
    requestData["cam"] = formatCamID(cameraId, eye);
    requestData["cam_path"] = path;
    requestData["fps"] = fps;
    requestData["width"] = width;
    requestData["height"] = height;

    QJsonDocument doc(requestData);
    qInfo() << doc;
    QByteArray data = doc.toJson();

    QNetworkReply* reply = ApiClient::instance()->post("/stream/config/start", data);
    connect(reply, &QNetworkReply::finished, this, &StreamController::onStreamStarted);
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

QString StreamController::formatCamID(const QString& id, const QString& eye)
{
    if (id == "cam1"){
        if (eye == "Left")
            return "caml1";
        else
            return "camr1";
    }
    else{
        if (eye == "Left")
            return "caml2";
        else
            return "camr2";
    }
}
