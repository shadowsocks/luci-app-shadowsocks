#
# Copyright (C) 2016 Jian Chang <aa65535@live.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-shadowsocks
PKG_VERSION:=1.1.1
PKG_RELEASE:=1

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jian Chang <aa65535@live.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-shadowsocks
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI Support for shadowsocks-libev
	PKGARCH:=all
	DEPENDS:=+ipset +ip
endef

define Package/luci-app-shadowsocks/description
	LuCI Support for shadowsocks-libev.
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/files/luci/i18n/*.po), \
		po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-shadowsocks/postinst
#!/bin/sh
uci -q batch <<-EOF >/dev/null 2>&1
	delete ucitrack.@shadowsocks[-1]
	add ucitrack shadowsocks
	set ucitrack.@shadowsocks[-1].init=shadowsocks
	commit ucitrack
	delete firewall.shadowsocks
	set firewall.shadowsocks=include
	set firewall.shadowsocks.type=script
	set firewall.shadowsocks.path=/var/etc/shadowsocks.include
	set firewall.shadowsocks.reload=1
	commit firewall
EOF
exit 0
endef

define Package/luci-app-shadowsocks/conffiles
/etc/config/shadowsocks
endef

define Package/luci-app-shadowsocks/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/shadowsocks.*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/luci/controller/*.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/shadowsocks
	$(INSTALL_DATA) ./files/luci/model/cbi/shadowsocks/*.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/root/etc/config/shadowsocks $(1)/etc/config/shadowsocks
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/root/etc/init.d/shadowsocks $(1)/etc/init.d/shadowsocks
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/root/usr/bin/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,luci-app-shadowsocks))
