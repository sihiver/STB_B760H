# Inherit some common AOSP ATV stuff.
$(call inherit-product, device/google/atv/products/atv_base.mk)

# Inherit from generic ATV product
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_atv_arm.mk)

# Inherit device configuration
$(call inherit-product, device/zte/b760h/device.mk)

# Product Name
PRODUCT_NAME := aosp_b760h

# Device identifier. This must come after all inclusions.
PRODUCT_DEVICE := b760h
PRODUCT_BRAND := ZTE
PRODUCT_MANUFACTURER := ZTE
PRODUCT_MODEL := B760H
