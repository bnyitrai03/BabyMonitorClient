#include "Camera.h"
#include <QJsonObject>
#include <QJsonValue>

Camera::Camera(const QJsonObject& data, QObject *parent) : QObject(parent)
{
    parseJsonData(data);
}

void Camera::parseJsonData(const QJsonObject& data)
{
    m_id = data["id"].toString();
    qInfo() << m_id;
    m_path = data["path"].toString();
    qInfo() << m_path;

    // Parse controls
    QJsonObject controlsObj = data["controls"].toObject();
    m_controls.clear();
    for (auto it = controlsObj.begin(); it != controlsObj.end(); ++it) {
        m_controls[it.key()] = it.value().toVariant();
        qInfo() << it.key() << " : " << it.value();
    }

    // Parse formats
    QJsonObject formatsObj = data["formats"].toObject();
    m_formats.clear();
    for (auto formatIt = formatsObj.begin(); formatIt != formatsObj.end(); ++formatIt) {
        QVariantMap resolutionMap;
        QJsonObject resolutions = formatIt.value().toObject();

        for (auto resIt = resolutions.begin(); resIt != resolutions.end(); ++resIt) {
            resolutionMap[resIt.key()] = resIt.value().toVariant();
        }

        m_formats[formatIt.key()] = resolutionMap;
    }
    qInfo() << m_formats;
}

void Camera::updateControls(const QVariantMap& controls)
{
    m_controls = controls;
    emit controlsChanged();
}

void Camera::updateFromJson(const QJsonObject& data)
{
    parseJsonData(data);
    emit controlsChanged();
}
