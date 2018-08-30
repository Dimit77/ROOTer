#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-update
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-update
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Basic Applications
  TITLE:=Add Firmware Update Check
  PKGARCH:=all
endef

define Package/ext-update/description
  Helper scripts to install Firmware Update Check
endef


define Build/Compile
endef

define Package/ext-update/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,ext-update))
