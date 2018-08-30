#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-rooter-mesh-4meg
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-rooter-mesh-4meg
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+luci +wpad-mini +mesh-basic 
  TITLE:=Support for Mesh routing on 4meg routers
  PKGARCH:=all
endef

define Package/ext-rooter-mesh-4meg/description
  Helper scripts to install Mesh on 4meg routers
endef

define Build/Compile
endef

define Package/ext-rooter-mesh-4meg/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,ext-rooter-mesh-4meg))
