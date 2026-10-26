# Inherit some common AOSP ATV stuff.
$(call inherit-product, device/google/atv/products/atv_base.mk)

# Product Name
PRODUCT_NAME := aosp_b760h

# Inherit device configuration
$(call inherit-product, device/zte/b760h/device.mk)

# Device identifier. This must come after all inclusions.
PRODUCT_DEVICE := b760h
PRODUCT_BRAND := google
PRODUCT_MANUFACTURER := Asus
PRODUCT_MODEL := Nexus Player
