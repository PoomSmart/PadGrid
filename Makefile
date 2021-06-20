export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
PACKAGE_VERSION = 1.0.3
TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PadGrid

$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(TWEAK_NAME)$(ECHO_END)
	$(ECHO_NOTHING)cp -r Resources $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(TWEAK_NAME)$(ECHO_END)
