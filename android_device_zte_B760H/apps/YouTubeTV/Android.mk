LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := YouTubeTV
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $(LOCAL_MODULE).apk
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_OVERRIDES_PACKAGES := YouTubeLeanback
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_DEX_PREOPT := false
LOCAL_PREBUILT_JNI_LIBS := \
    @lib/armeabi-v7a/libcoat.so \
    @lib/armeabi-v7a/libcronet.96.0.4655.4.so \
    @lib/armeabi-v7a/libelements.so \
    @lib/armeabi-v7a/libframesequence.so \
    @lib/armeabi-v7a/libjsc.so \
    @lib/armeabi-v7a/libnativecrashdetectorutil.so \
    @lib/armeabi-v7a/libyoga.so
include $(BUILD_PREBUILT)

