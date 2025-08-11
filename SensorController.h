#ifndef SENSORCONTROLLER_H
#define SENSORCONTROLLER_H

#include <QObject>
#include <QString>
#include <QTimer>
#include <QFile>
#include <QTextStream>
#include <QDir>

class SensorController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double luxValue READ get_luxValue NOTIFY sensorDataChanged)
    Q_PROPERTY(double tempValue READ get_tempValue NOTIFY sensorDataChanged)
    Q_PROPERTY(int luxThreshold READ get_luxThreshold NOTIFY sensorDataChanged)
    Q_PROPERTY(QString timestamp READ get_timestamp NOTIFY sensorDataChanged)
    Q_PROPERTY(double ledBrightness READ get_ledBrightness NOTIFY sensorDataChanged)
    Q_PROPERTY(bool online READ get_online NOTIFY sensorDataChanged)

public:
    explicit SensorController(QObject *parent = nullptr);

    Q_INVOKABLE void refreshData();
    Q_INVOKABLE void updateLuxThreshold(int threshold);
    Q_INVOKABLE void updateLedBrightness(double brightness);

    double get_luxValue() const;
    double get_tempValue() const;
    int get_luxThreshold() const;
    double get_ledBrightness() const;
    QString get_timestamp() const;
    bool get_online() const;

signals:
    void sensorDataChanged();

private:
    void parseSensorData(const QByteArray& data);
    void saveToCsv();

    double m_luxValue = 0.0;
    double m_tempValue = 0.0;
    int m_luxThreshold = 0;
    double m_ledBrightness = 0.5;
    QString m_timestamp;
    QTimer m_refreshTimer;
    bool m_online = false;
    QString m_csvFilePath = QDir::currentPath() + "/sensor_log.csv";
};

#endif // SENSORCONTROLLER_H
