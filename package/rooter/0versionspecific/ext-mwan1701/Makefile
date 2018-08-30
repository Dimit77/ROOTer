#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-mwan1701
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-mwan1701
  SECTION:=utils
  SUBMENU:=Optional Applications
  CATEGORY:=ROOter
  DEPENDS:=+luci-app-mwan3 +luci-app-dnsmasq-ipset
  TITLE:=Helper scripts to modify MWan3 on 1701
  PKGARCH:=all
endef

define Package/ext-mwan1701/description
  Helper scripts to modify MWan3 on 1701
endef


define Build/Compile
endef

define Package/ext-mwan1701/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,ext-mwan1701))
