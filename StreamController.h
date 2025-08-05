#ifndef STREAMCONTROLLER_H
#define STREAMCONTROLLER_H

#include <QObject>
#include <QUrl>

class StreamController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl streamUrl READ streamUrl NOTIFY streamUrlChanged)
    Q_PROPERTY(bool streaming READ streaming NOTIFY streamingChanged)

public:
    explicit StreamController(QObject *parent = nullptr);

    QUrl streamUrl() const { return m_streamUrl; }
    bool streaming() const { return m_streaming; }

    Q_INVOKABLE void startStream(const QString& cameraId, const QString& cameraPath, const QString& eye, int fps, int width, int height);
    Q_INVOKABLE void stopStream();

signals:
    void streamUrlChanged();
    void streamingChanged();
    void error(const QString& message);

private slots:
    void onStreamStarted();
    void onStreamStopped();

private:
    void setStreamUrl(const QUrl& url);
    void setStreaming(bool streaming);
    QString formatCamID(const QString& id, const QString& eye);

    QUrl m_streamUrl;
    bool m_streaming = false;
};

#endif // STREAMCONTROLLER_H
