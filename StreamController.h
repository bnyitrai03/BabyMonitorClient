#ifndef STREAMCONTROLLER_H
#define STREAMCONTROLLER_H

#include <QObject>
#include <QUrl>

class StreamController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl streamUrl READ streamUrl NOTIFY streamUrlChanged)
    Q_PROPERTY(bool streaming READ streaming NOTIFY streamingChanged)
    Q_PROPERTY(QString currentCameraId READ currentCameraId NOTIFY currentCameraIdChanged)

public:
    explicit StreamController(QObject *parent = nullptr);

    QUrl streamUrl() const { return m_streamUrl; }
    bool streaming() const { return m_streaming; }
    QString currentCameraId() const { return m_currentCameraId; }

    Q_INVOKABLE void startStream(const QString& cameraId, const QString& cameraPath, int fps, int width, int height);
    Q_INVOKABLE void stopStream();

signals:
    void streamUrlChanged();
    void streamingChanged();
    void currentCameraIdChanged();
    void error(const QString& message);

private slots:
    void onStreamStarted();
    void onStreamStopped();

private:
    void setStreamUrl(const QUrl& url);
    void setStreaming(bool streaming);
    void setCurrentCameraId(const QString& cameraId);

    QUrl m_streamUrl;
    bool m_streaming = false;
    QString m_currentCameraId;
};

#endif // STREAMCONTROLLER_H
