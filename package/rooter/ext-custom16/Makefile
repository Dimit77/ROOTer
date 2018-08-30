#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-custom16
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-custom16
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+luci +luci-app-sqm +luci-app-rooterddns +luci-app-rootervpn +ext-mwansnap \
		+ext-rooter-basic +ext-p910nd +ext-samba +customize \
		+ext-umount +ext-command +kmod-sched-cake \
		+openvpn-easy-rsa +openvpn-openssl +wget +ext-extra +wpad-mini \
		+nano +picocom +bwmon +luci-app-hotspot +luci-app-wol
  TITLE:=Custom ROOter support for 16meg and larger routers
  PKGARCH:=all
endef

define Package/ext-custom16/description
  Helper scripts to enable Custom ROOter on 16meg and larger routers
endef


define Build/Compile
endef

define Package/ext-custom16/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,ext-custom16))
