#include "CameraController.h"
#include "ApiClient.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkReply>

CameraController::CameraController(QObject *parent) : QObject(parent)
{
    refreshCameras();
}

QQmlListProperty<Camera> CameraController::cameras()
{
    return QQmlListProperty<Camera>(this, &m_cameras, &camerasCount, &camerasAt);
}

void CameraController::refreshCameras()
{
    QNetworkReply* reply = ApiClient::instance()->get("/cameras");
    connect(reply, &QNetworkReply::finished, this, &CameraController::onCamerasReceived);
}

void CameraController::updateCameraControls(const QString& cameraId, const QVariantMap& controls)
{
    QJsonObject requestData;
    QJsonObject controlsObj;

    for (auto it = controls.begin(); it != controls.end(); ++it) {
        controlsObj[it.key()] = QJsonValue::fromVariant(it.value());
    }
    requestData["controls"] = controlsObj;

    QJsonDocument doc(requestData);
    QByteArray data = doc.toJson();

    QString endpoint = "/cameras/" + cameraId + "/controls";
    QNetworkReply* reply = ApiClient::instance()->put(endpoint, data);
    // Let's assume the API returns the updated camera object on success
    connect(reply, &QNetworkReply::finished, this, &CameraController::onControlsUpdated);
}

void CameraController::resetCameraControls(const QString& cameraId)
{
    QString endpoint = "/cameras/" + cameraId + "/reset";
    QNetworkReply* reply = ApiClient::instance()->put(endpoint, QByteArray());
    // Also connect to the same slot to handle the response
    connect(reply, &QNetworkReply::finished, this, &CameraController::onControlsUpdated);
}

void CameraController::onCamerasReceived()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply){
        emit error("Did not receive reply from server");
        return;
    }

    if (reply->error() == QNetworkReply::NoError) {
        parseCamerasData(reply->readAll());
    } else {
        emit error("Failed to load cameras: " + reply->errorString());
    }
    reply->deleteLater();
}

void CameraController::onControlsUpdated()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        // Assuming the API returns the full updated camera JSON object in the body
        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        if (doc.isObject()) {
            QJsonObject cameraData = doc.object();
            QString cameraId = cameraData["id"].toString();
            Camera* camera = findCameraById(cameraId);
            if (camera) {
                camera->updateFromJson(cameraData);
            }
        }
    } else {
        emit error("Failed to update camera controls: " + reply->errorString());
    }
    reply->deleteLater();
}

void CameraController::parseCamerasData(const QByteArray& data)
{
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isArray()) {
        emit error("Invalid camera data message format");
        return;
    }

    qDeleteAll(m_cameras);
    m_cameras.clear();

    QJsonArray camerasArray = doc.array();
    for (const QJsonValue& value : std::as_const(camerasArray)) {
        if (value.isObject()) {
            Camera* camera = new Camera(value.toObject(), this);
            m_cameras.append(camera);
        }
    }

    emit camerasChanged();
}

Camera* CameraController::findCameraById(const QString& cameraId)
{
    for (Camera* cam : std::as_const(m_cameras)) {
        if (cam->id() == cameraId) {
            return cam;
        }
    }
    return nullptr;
}

//--- Helper function implementations  ---

QStringList CameraController::getFormatsForCamera(const QString& cameraId)
{
    Camera* camera = findCameraById(cameraId);
    return camera ? camera->formats().keys() : QStringList();
}

QStringList CameraController::getResolutionsForFormat(const QString& cameraId, const QString& format)
{
    Camera* camera = findCameraById(cameraId);
    if (camera) {
        QVariantMap formats = camera->formats();
        if (formats.contains(format)) {
            return formats[format].toMap().keys();
        }
    }
    return QStringList();
}

QList<int> CameraController::getFpsForResolution(const QString& cameraId, const QString& format, const QString& resolution)
{
    Camera* camera = findCameraById(cameraId);
    if (camera) {
        QVariantMap formats = camera->formats();
        if (formats.contains(format)) {
            QVariantMap resolutions = formats[format].toMap();
            if (resolutions.contains(resolution)) {
                QVariantList fpsList = resolutions[resolution].toList();
                QList<int> result;
                for (const QVariant& fps : std::as_const(fpsList)) {
                    result.append(fps.toInt());
                }
                return result;
            }
        }
    }
    return QList<int>();
}

qsizetype CameraController::camerasCount(QQmlListProperty<Camera>* list)
{
    return static_cast<QList<Camera*>*>(list->data)->size();
}

Camera* CameraController::camerasAt(QQmlListProperty<Camera>* list, qsizetype index)
{
    return static_cast<QList<Camera*>*>(list->data)->at(index);
}
