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
    QNetworkReply* patch(const QString& endpoint, const QByteArray& data);
    QNetworkReply* post(const QString& endpoint, const QByteArray& data);

private:
    explicit ApiClient(QObject *parent = nullptr);
    ApiClient(const ApiClient&) = delete;
    ApiClient& operator=(const ApiClient&) = delete;

    QNetworkAccessManager m_networkManager;
     QSslConfiguration m_sslConfig;
    const QString m_baseUrl = "https://rpicm5";
};

#endif // APICLIENT_H
