ARCHS = armv7
TARGET = iphone:clang:6.1:5.1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = iPad1Downloader

iPad1Downloader_FILES = \
    src/main.m \
    src/AppDelegate.m \
    src/UnifiedAppDelegate.m \
    src/FTPPathUtils.m \
    src/FTPDownloader.m \
    src/FTPUploader.m \
    src/FTPBrowser.m \
    src/FTPCommandClient.m \
    src/HTTPDownloadTask.m \
    src/HTTPDownloadViewController.m \
    src/WiFiReceiveServer.m \
    src/WiFiReceiveViewController.m

iPad1Downloader_FRAMEWORKS = UIKit Foundation CFNetwork
iPad1Downloader_CFLAGS = -fno-objc-arc -Wall
iPad1Downloader_RESOURCE_FILES = Info.plist

include $(THEOS_MAKE_PATH)/application.mk
