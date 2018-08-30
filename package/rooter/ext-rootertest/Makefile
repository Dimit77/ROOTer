#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-rootertest
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

#		+luci-app-mwan3 +luci-app-dnsmasq-ipset \
#		+ext-samba +ext-umount +luci-app-hotspot  \

define Package/ext-rootertest
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+luci +ext-rooter-basic +nano +picocom +wget +ext-extra +ext-command \
		+luci-app-rooterddns \
		+luci-app-sqm +kmod-sched-cake \
		+ext-p910nd +luci-app-rootervpn +openvpn-easy-rsa +openvpn-openssl \
		+luci-app-mwan3 +luci-app-dnsmasq-ipset \
		+bwmon +wpad +luci-app-hotspot +ext-samba +ext-umount
  TITLE:=ROOter support for 8meg and larger routers
  PKGARCH:=all
endef

define Package/ext-rootertest/description
  Helper scripts to enable ROOter on 8meg and larger routers
endef


define Build/Compile
endef

define Package/ext-rootertest/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,ext-rootertest))
