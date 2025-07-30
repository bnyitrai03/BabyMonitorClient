#ifndef CAMERA_H
#define CAMERA_H

#include <QObject>
#include <QString>
#include <QJsonObject>
#include <QVariantMap>

class Camera : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QVariantMap controls READ controls NOTIFY controlsChanged)
    Q_PROPERTY(QVariantMap formats READ formats CONSTANT)

public:
    explicit Camera(QObject *parent = nullptr) {};
    Camera(const QJsonObject& data, QObject *parent = nullptr);

    QString id() const { return m_id; }
    QString name() const { return m_name; }
    QVariantMap controls() const { return m_controls; }
    QVariantMap formats() const { return m_formats; }

    void updateControls(const QVariantMap& controls);
    void updateFromJson(const QJsonObject& data);

signals:
    void controlsChanged();

private:
    QString m_id;
    QString m_name;
    QVariantMap m_controls;
    QVariantMap m_formats;

    void parseJsonData(const QJsonObject& data);
};

#endif // CAMERA_H
