cmake_minimum_required(VERSION 3.16)

project(BabyMonitor VERSION 1.0 LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Quick Gui Network Multimedia QuickControls2)

qt_standard_project_setup(REQUIRES 6.8)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

qt_add_executable(BabyMonitorUI
    main.cpp
)

qt_add_qml_module(BabyMonitorUI
    URI BabyMonitor
    VERSION 1.0
    QML_FILES
        MainView.qml
        SensorView.qml
        CameraStreamView.qml
        CameraSettingsMenu.qml
        CustomSlider.qml
    SOURCES
        ApiClient.h
        ApiClient.cpp
        SensorController.h
        SensorController.cpp
        StreamController.h
        StreamController.cpp
        CameraController.h
        CameraController.cpp
        Camera.h
        Camera.cpp
        Config.h
)

target_link_libraries(BabyMonitorUI
    PRIVATE
        Qt6::Gui
        Qt6::Quick
        Qt6::Network
        Qt6::Multimedia
        Qt6::QuickControls2
)
