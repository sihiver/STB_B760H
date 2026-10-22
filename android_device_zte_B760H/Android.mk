LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),B760H)

include $(call all-makefiles-under,$(LOCAL_PATH))

endif