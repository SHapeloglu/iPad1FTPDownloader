ARCHS = armv7
TARGET = iphone:clang:6.1:5.1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = iPad1FTPDownloader

iPad1FTPDownloader_FILES = \
    src/main.m \
    src/AppDelegate.m \
    src/FTPDownloader.m \
    src/FTPUploader.m \
    src/FTPBrowser.m \
    src/FTPCommandClient.m

iPad1FTPDownloader_FRAMEWORKS = UIKit Foundation CFNetwork
iPad1FTPDownloader_CFLAGS = -fno-objc-arc
iPad1FTPDownloader_RESOURCE_FILES = Info.plist

include $(THEOS_MAKE_PATH)/application.mk
