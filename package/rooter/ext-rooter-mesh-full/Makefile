#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-rooter-mesh-full
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-rooter-mesh-full
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+mesh-full +luci +ext-rooter-basic +nano +picocom \
	+luci-app-sqm  +kmod-sched-cake \
	+luci-app-rooterddns +ext-mwansnap \
	+ext-samba +ext-umount \
	+ext-command +ext-extra +ext-p910nd +ext-update \
	+luci-app-rootervpn +openvpn-easy-rsa +openvpn-openssl \
	+bwmon +luci-app-hotspot +luci-app-wol
  TITLE:=Support for Mesh routing for 16meg routers
  PKGARCH:=all
endef

define Package/ext-rooter-mesh-full/description
  Helper scripts to install Meshing on ROOter 16meg routers
endef

define Build/Compile
endef

$(eval $(call BuildPackage,ext-rooter-mesh-full))
