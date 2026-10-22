DEVICE_DIR := device/zte/B760H
VENDOR_DIR := vendor/zte/B760H

# Inherit some common stuff.
$(call inherit-product, vendor/cm/config/common_full_tablet_wifionly.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# call dalvik heap config & hwui memory config (1GB RAM box)
$(call inherit-product, frameworks/native/build/phone-xhdpi-1024-dalvik-heap.mk)
$(call inherit-product-if-exists, frameworks/native/build/phone-xxhdpi-2048-hwui-memory.mk)

# Inherit device configuration
$(call inherit-product, $(DEVICE_DIR)/full_B760H.mk)
$(call inherit-product, $(DEVICE_DIR)/device.mk)

# Get non-open-source device specific aspects
$(call inherit-product-if-exists, $(VENDOR_DIR)/B760H-vendor.mk)

# TV/STB Artwork configs
PRODUCT_AAPT_CONFIG := normal hdpi xhdpi tvdpi
PRODUCT_AAPT_PREF_CONFIG := hdpi
PRODUCT_AAPT_PREBUILT_DPI := hdpi tvdpi mdpi

# Device identifier. This must come after all inclusions
PRODUCT_DEVICE := B760H
PRODUCT_NAME := lineage_B760H
PRODUCT_MODEL := ZTE B760H
PRODUCT_MANUFACTURER := ZTE
PRODUCT_BRAND := ZTE
PRODUCT_RELEASE_NAME := B760H
PRODUCT_CHARACTERISTICS := box
TARGET_VENDOR_RELEASE_BUILD_ID := B760H_LOS141V1
TARGET_VENDOR_PRODUCT_NAME := ZTEB760H
TARGET_VENDOR_DEVICE_NAME := B760H

# Resolution (HDMI 1080p)
TARGET_SCREEN_WIDTH := 1920
TARGET_SCREEN_HEIGHT := 1080

