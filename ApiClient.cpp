#include "ApiClient.h"
#include <QNetworkRequest>
#include <QSslConfiguration>
#include <QSslCertificate>
#include <QNetworkReply>
#include <QSslSocket>

ApiClient* ApiClient::instance()
{
    static ApiClient client;
    return &client;
}

ApiClient::ApiClient(QObject *parent) : QObject(parent)
{
}

void ApiClient::setUrlandCert(const QString& name)
{
    //eg.: https://babymonitor1
    m_baseUrl = QString("https://%1").arg(name.toLower());

    QString certPem = name.contains("1") ? DEVICE1_CERT : DEVICE2_CERT;
    QSslCertificate cert(certPem.toUtf8(), QSsl::Pem);
    m_sslConfig = QSslConfiguration::defaultConfiguration();
    QList<QSslCertificate> caCerts = m_sslConfig.caCertificates();
    caCerts.append(cert);
    m_sslConfig.setCaCertificates(caCerts);

    connect(&m_networkManager, &QNetworkAccessManager::sslErrors,
            [](QNetworkReply* reply, const QList<QSslError>& errors) {
                qWarning() << "SSL Errors:";
                for (const auto& e : errors)
                    qWarning() << " -" << e.errorString();
            });

    qInfo("ApiClient has connected!");
}

QNetworkReply* ApiClient::get(const QString& endpoint)
{
    QNetworkRequest request(QUrl(m_baseUrl + endpoint));
    request.setSslConfiguration(m_sslConfig);
    request.setAttribute(QNetworkRequest::Http2AllowedAttribute, false); // Force HTTP/1.1
    request.setRawHeader("Connection", "keep-alive");
    return m_networkManager.get(request);
}

QNetworkReply* ApiClient::put(const QString& endpoint, const QByteArray& data)
{
    QNetworkRequest request(QUrl(m_baseUrl + endpoint));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setSslConfiguration(m_sslConfig);
    request.setAttribute(QNetworkRequest::Http2AllowedAttribute, false);
    return m_networkManager.put(request, data);
}

QNetworkReply* ApiClient::post(const QString& endpoint, const QByteArray& data)
{
    QNetworkRequest request(QUrl(m_baseUrl + endpoint));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setSslConfiguration(m_sslConfig);
    request.setAttribute(QNetworkRequest::Http2AllowedAttribute, false);
    return m_networkManager.post(request, data);
}
