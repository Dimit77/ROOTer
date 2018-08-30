#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-rooter-mesh-lite
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-rooter-mesh-lite
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+luci +mesh-full +ext-update 
  TITLE:=Support for Mesh routing w/o ROOter support
  PKGARCH:=all
endef

define Package/ext-rooter-mesh-lite/description
  Helper scripts to install Mesh routing w/o ROOter support
endef

define Build/Compile
endef

$(eval $(call BuildPackage,ext-rooter-mesh-lite))
