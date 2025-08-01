#ifndef CAMERACONTROLLER_H
#define CAMERACONTROLLER_H

#include <QObject>
#include <QQmlListProperty>
#include <QList>
#include "Camera.h"

class CameraController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<Camera> cameras READ cameras NOTIFY camerasChanged)
    Q_PROPERTY(Camera* activeCamera READ activeCamera WRITE setActiveCamera NOTIFY activeCameraChanged)

public:
    explicit CameraController(QObject *parent = nullptr);

    QQmlListProperty<Camera> cameras();
    Camera* activeCamera() const { return m_activeCamera; }

    Q_INVOKABLE void setActiveCamera(Camera* camera);
    Q_INVOKABLE void refreshCameras();
    Q_INVOKABLE void updateCameraControl(const QString& cameraId, const QString& controlName, const QVariant& value);
    Q_INVOKABLE void resetCameraControls(const QString& cameraId);

    // Helper functions for QML, moved from the old controller
    Q_INVOKABLE QStringList getFormatsForCamera(const QString& cameraId);
    Q_INVOKABLE QStringList getResolutionsForFormat(const QString& cameraId, const QString& format);
    Q_INVOKABLE QList<int> getFpsForResolution(const QString& cameraId, const QString& format, const QString& resolution);
signals:
    void camerasChanged();
    void activeCameraChanged();
    void error(const QString& message);

private slots:
    void onCamerasReceived();
    void onControlsUpdated();

private:
    void parseCamerasData(const QByteArray& data);
    Camera* findCameraById(const QString& cameraId);

    // QQmlListProperty helper functions
    static qsizetype camerasCount(QQmlListProperty<Camera>* list);
    static Camera* camerasAt(QQmlListProperty<Camera>* list, qsizetype index);

    QList<Camera*> m_cameras;
    Camera* m_activeCamera = nullptr;
};

#endif // CAMERACONTROLLER_H
