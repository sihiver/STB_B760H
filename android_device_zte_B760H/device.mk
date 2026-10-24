DEVICE_PATH := device/zte/b760h
VENDOR_PATH := vendor/zte/b760h

# Inherit the proprietary configuration.
$(call inherit-product, $(VENDOR_PATH)/b760h-vendor.mk)

# Dalvik/HWUI
$(call inherit-product, frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk)
$(call inherit-product-if-exists, frameworks/native/build/phone-xxhdpi-2048-hwui-memory.mk)

# Gapps
$(call inherit-product-if-exists, vendor/gapps/arm_tvstock/arm_tvstock-vendor.mk)

# Characteristics
PRODUCT_CHARACTERISTICS := tv
PRODUCT_SHIPPING_API_LEVEL := 19

# Boot animation
TARGET_BOOTANIMATION_MULTITHREAD_DECODE := true
TARGET_SCREEN_WIDTH := 1920
TARGET_SCREEN_HEIGHT := 1080
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/bootanimation.zip:system/media/bootanimation.zip

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(DEVICE_PATH)/configs/overlay/tvmini \
    $(DEVICE_PATH)/configs/overlay/device

# Permissions/features
PERM_PATH := frameworks/native/data/etc
PERM_DEST := system/etc/permissions

PRODUCT_COPY_FILES += \
    $(PERM_PATH)/android.hardware.bluetooth.xml:$(PERM_DEST)/android.hardware.bluetooth.xml \
    $(PERM_PATH)/android.hardware.bluetooth_le.xml:$(PERM_DEST)/android.hardware.bluetooth_le.xml \
    $(PERM_PATH)/android.hardware.usb.host.xml:$(PERM_DEST)/android.hardware.usb.host.xml \
    $(PERM_PATH)/android.hardware.wifi.xml:$(PERM_DEST)/android.hardware.wifi.xml \
    $(PERM_PATH)/android.hardware.wifi.direct.xml:$(PERM_DEST)/android.hardware.wifi.direct.xml \
    $(PERM_PATH)/android.hardware.ethernet.xml:$(PERM_DEST)/android.hardware.ethernet.xml

# Init & Helpers
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,${DEVICE_PATH}/configs/init,root) \
    $(DEVICE_PATH)/configs/helpers/net_helper.sh:system/bin/net_helper.sh

# Recovery
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,${DEVICE_PATH}/configs/recovery,recovery/root)

# WiFi
PRODUCT_PACKAGES += \
    libwpa_client \
    hostapd \
    wpa_supplicant \
    wpa_supplicant.conf \
    wificond

# Bluetooth
PRODUCT_PACKAGES += \
     libbt-vendor

# Audio
PRODUCT_PACKAGES += \
    audio.primary.mt8127 \
    audio.a2dp.default \
    audio_policy.default \
    audio_policy.stub \
    audio.r_submix.default \
    audio.usb.default \
    audio.primary.default \
    libaudio-resampler

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/init/audioserver.rc:system/etc/init/audioserver.rc

# OMX
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/configs/media,system/etc) \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:system/etc/media_codecs_google_telephony.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video_le.xml:system/etc/media_codecs_google_video_le.xml

# Root
PRODUCT_PACKAGES += \
    su

# Remote
PRODUCT_PACKAGES += \
    ir_daemon \
    ir_daemon_recovery

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/libs/remote/ir_custom.template:$(TARGET_COPY_OUT_VENDOR)/etc/ir_custom.conf

# HDMI
PRODUCT_PACKAGES += \
    hdmi_helper

# Shims/stubs
PRODUCT_PACKAGES += \
    libcorkscrew \
    libshim_ui \
    libshim_gui \
    libshim_utils \
    libshim_audio\
    libshim_omx \
    libshim_log

# Dependencies
PRODUCT_PACKAGES += \
    libm4u \
    libdpframework

# Settings
ifneq (,$(filter lineage_b760h,$(PRODUCT_NAME) $(TARGET_PRODUCT)))
PRODUCT_PACKAGES += \
    TvSettingsMTK
endif

# Time
PRODUCT_PACKAGES += \
    savetime \
    restoretime

# Extras
ifneq (,$(filter lineage_b760h,$(PRODUCT_NAME) $(TARGET_PRODUCT)))
PRODUCT_PACKAGES += \
    Trebuchet
endif

PRODUCT_PACKAGES += \
    LeanKeyboard \
    DocumentsUI \
    WebViewGoogle \
    SetupWraith \
    B760HSetupCustomizer \
    Overscan

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/init/keyboard.rc:system/etc/init/keyboard.rc

# Remove packages
PRODUCT_PACKAGES += RemovePackages