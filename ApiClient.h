#ifndef APICLIENT_H
#define APICLIENT_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrl>

class ApiClient : public QObject
{
    Q_OBJECT
public:
    static ApiClient* instance();

    QNetworkReply* get(const QString& endpoint);
    QNetworkReply* put(const QString& endpoint, const QByteArray& data);
    QNetworkReply* post(const QString& endpoint, const QByteArray& data);

public slots:
    void setUrlandCert(const QString& name);

signals:
    void error(const QString& message);

private:
    explicit ApiClient(QObject *parent = nullptr);
    ApiClient(const ApiClient&) = delete;
    ApiClient& operator=(const ApiClient&) = delete;

    QNetworkAccessManager m_networkManager;
    QSslConfiguration m_sslConfig;
    QString m_baseUrl;
};

#endif // APICLIENT_H
