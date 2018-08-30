#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-rooter-mesh-mini
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-rooter-mesh-mini
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+luci +mesh-full +ext-rooter-basic +nano +picocom +ext-update 
  TITLE:=Support for Mesh routing for 8meg routers
  PKGARCH:=all
endef

define Package/ext-rooter-mesh-mini/description
  Helper scripts to install Meshing on ROOter 8meg routers
endef

define Build/Compile
endef

$(eval $(call BuildPackage,ext-rooter-mesh-mini))
