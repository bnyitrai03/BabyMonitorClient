#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "SensorController.h"
#include "StreamController.h"
#include "CameraController.h"
#include "Camera.h"
#include "ApiClient.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // Register C++ data model with the QML type system
    qmlRegisterType<Camera>("BabyMonitor.Models", 1, 0, "Camera");

    // Instantiate controllers
    SensorController sensorController;
    StreamController streamController;
    CameraController cameraController;

    // Expose C++ controller instances to QML
    QQmlContext *rootContext = engine.rootContext();
    rootContext->setContextProperty("sensorController", &sensorController);
    rootContext->setContextProperty("streamController", &streamController);
    rootContext->setContextProperty("cameraController", &cameraController);
    rootContext->setContextProperty("ApiClient", ApiClient::instance());


    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [&](QObject *obj, const QUrl &objUrl) {
            if (!obj) {
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection);

    engine.loadFromModule("BabyMonitor", "MainView");

    return app.exec();
}
