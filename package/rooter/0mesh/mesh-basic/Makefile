#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=mesh-basic
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/mesh-basic
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Mesh Support
  DEPENDS:=+kmod-batman-adv +alfred +batctl +ip +kmod-rt2800-usb
  TITLE:=Support for Mesh routing
  PKGARCH:=all
endef

define Package/mesh-basic/description
  Helper scripts to install Mesh
endef

define Build/Compile
endef

define Package/mesh-basic/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,mesh-basic))
