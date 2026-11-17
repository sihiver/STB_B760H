LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := MqlTV
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $(LOCAL_MODULE).apk
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_DEX_PREOPT := false
LOCAL_PREBUILT_JNI_LIBS := \
    @lib/armeabi-v7a/libc++_shared.so \
    @lib/armeabi-v7a/libconscrypt_jni.so \
    @lib/armeabi-v7a/libffmpegJNI.so \
    @lib/armeabi-v7a/libvlc.so \
    @lib/armeabi-v7a/libvlcjni.so
include $(BUILD_PREBUILT)

