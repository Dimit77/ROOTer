#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-rooterbcm8
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-rooterbcm8
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+luci +luci-app-sqm +luci-app-ddns +ext-mwansnap \
		+ext-rooter-basic +ext-p910nd +ext-samba +ext-update \
		+ext-umount +ext-command +kmod-sched-cake \
		+wget +ext-extra \
		+nano +picocom +bwmon +luci-app-wol +wpad-mini 
  TITLE:=ROOter support for 8meg Broadcom routers w/o OpenVPN
  PKGARCH:=all
endef

define Package/ext-rooterbcm8/description
  Helper scripts to enable ROOter on 8meg Broadcom routers w/o OpenVPN
endef


define Build/Compile
endef

define Package/ext-rooterbcm8/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,ext-rooterbcm8))
