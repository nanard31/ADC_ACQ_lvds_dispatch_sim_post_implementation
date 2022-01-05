TEMPLATE = app
CONFIG += console c++11
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += \
        RAMTester.cpp \
        mt_random.cpp

HEADERS += \
    okFrontPanel.h \
    okFrontPanelDLL.h

LIBS += okFrontPanel.lib
