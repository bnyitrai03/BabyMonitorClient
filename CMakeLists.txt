cmake_minimum_required(VERSION 3.16)

project(BabyMonitor VERSION 1.0 LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Quick Gui Network Multimedia)

qt_standard_project_setup(REQUIRES 6.8)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

qt_add_executable(BabyMonitorClient
    main.cpp
)

qt_add_qml_module(BabyMonitorClient
    URI BabyMonitor
    VERSION 1.0
    QML_FILES
        MainView.qml
        SensorView.qml
    SOURCES
        main.h
        main.cpp
)

target_link_libraries(BabyMonitorClient 
    PRIVATE
        Qt6::Gui
        Qt6::Quick
        Qt6::Network
        Qt6::Multimedia
)
