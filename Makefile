#
# Copyright (C) 2016-2021 Jian Chang <aa65535@live.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-shadowsocks
PKG_VERSION:=2.0.3
PKG_RELEASE:=1

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jian Chang <aa65535@live.com>

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-shadowsocks/Default
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI Support for shadowsocks-libev
	PKGARCH:=all
	DEPENDS:=+iptables +wget +resolveip $(1)
endef

Package/luci-app-shadowsocks = $(call Package/luci-app-shadowsocks/Default,+ipset)
Package/luci-app-shadowsocks-without-ipset = $(call Package/luci-app-shadowsocks/Default)

define Package/luci-app-shadowsocks/description
	LuCI Support for shadowsocks-libev.
endef

Package/luci-app-shadowsocks-without-ipset/description = $(Package/luci-app-shadowsocks/description)

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-shadowsocks/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/uci-defaults/luci-shadowsocks ]; then
		( . /etc/uci-defaults/luci-shadowsocks ) && \
		rm -f /etc/uci-defaults/luci-shadowsocks
	fi
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
fi
exit 0
endef

Package/luci-app-shadowsocks-without-ipset/postinst = $(Package/luci-app-shadowsocks/postinst)

define Package/luci-app-shadowsocks/conffiles
/etc/config/shadowsocks
endef

Package/luci-app-shadowsocks-without-ipset/conffiles = $(Package/luci-app-shadowsocks/conffiles)

define Package/luci-app-shadowsocks/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/
	cp -pR ./root/* $(1)/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/shadowsocks.po $(1)/usr/lib/lua/luci/i18n/shadowsocks.zh-cn.lmo
endef

Package/luci-app-shadowsocks-without-ipset/install = $(call Package/luci-app-shadowsocks/install,$(1),-without-ipset)

$(eval $(call BuildPackage,luci-app-shadowsocks))
$(eval $(call BuildPackage,luci-app-shadowsocks-without-ipset))
