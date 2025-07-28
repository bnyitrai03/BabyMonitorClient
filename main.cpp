#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "SensorController.h"
#include "CameraStreamController.h"
#include "Camera.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // Register C++ data models with the QML type system
    //qmlRegisterType<Camera>("BabyMonitor.Models", 1, 0, "Camera");

    // Instantiate controllers
    SensorController sensorController;
    //CameraStreamController camerastreamController;

    // Expose C++ controller instances to QML
    QQmlContext *rootContext = engine.rootContext();
    rootContext->setContextProperty("sensorController", &sensorController);
    //rootContext->setContextProperty("camerastreamController", &camerastreamController);

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
