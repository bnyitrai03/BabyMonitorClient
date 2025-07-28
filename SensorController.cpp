#include "SensorController.h"
#include "ApiClient.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>

SensorController::SensorController(QObject *parent) : QObject(parent)
{
    connect(&m_refreshTimer, &QTimer::timeout, this, &SensorController::refreshData);
    m_refreshTimer.start(1000); // Refresh every second
    refreshData();
}

void SensorController::refreshData()
{
    QNetworkReply* reply = ApiClient::instance()->get("/sensors");
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            parseSensorData(reply->readAll());
        } else {
            m_online = false;
            emit sensorDataChanged();
        }
        reply->deleteLater();
    });
}

void SensorController::updateLuxThreshold(int threshold)
{
    QNetworkReply* reply = ApiClient::instance()->patch("/sensors/lux_threshold", QByteArray::number(threshold));
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            refreshData(); // Refresh data to show new threshold
        } else {
            m_online = false;
            emit sensorDataChanged();
        }
        reply->deleteLater();
    });
}

void SensorController::parseSensorData(const QByteArray &data)
{
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isObject()){
        setDummyDataOnError();
    }
    else {
        QJsonObject obj = doc.object();
        m_luxValue = obj["lux_value"].toDouble();
        m_tempValue = obj["temp_value"].toDouble();
        m_luxThreshold = obj["lux_threshold"].toInt();
        m_timestamp = obj["timestamp"].toString();
        m_online = true;
    }

    emit sensorDataChanged();
}

void SensorController::setDummyDataOnError()
{
    m_luxValue = 0;
    m_tempValue = 0;
    m_luxThreshold = -1;
    m_timestamp = "N/A";
    m_online = false;
}

double SensorController::get_luxValue() const { return m_luxValue; }
double SensorController::get_tempValue() const { return m_tempValue; }
int SensorController::get_luxThreshold() const { return m_luxThreshold; }
void SensorController::set_luxThreshold(int threshold){m_luxThreshold = threshold; }
QString SensorController::get_timestamp() const { return m_timestamp; }
bool SensorController::get_online() const { return m_online; }
