#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=mesh-full
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/mesh-full
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Mesh Support
  DEPENDS:=+mesh-basic +wget +wpad 
  TITLE:=Support for Mesh routing
  PKGARCH:=all
endef

define Package/mesh-full/description
  Helper scripts to install Meshing
endef

define Build/Compile
endef

define Package/mesh-full/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,mesh-full))
