#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-mwansnap
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-mwansnap
  SECTION:=utils
  SUBMENU:=Optional Applications
  CATEGORY:=ROOter
  DEPENDS:=+luci-app-mwan3 +luci-app-dnsmasq-ipset
  TITLE:=Helper scripts to modify MWan3 on 1701
  PKGARCH:=all
endef

define Package/ext-mwansnap/description
  Helper scripts to modify MWan3 on 1701
endef


define Build/Compile
endef

define Package/ext-mwansnap/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,ext-mwansnap))
