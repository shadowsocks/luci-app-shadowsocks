-- Copyright (C) 2016 Jian Chang <aa65535@live.com>
-- Licensed to the public under the GNU General Public License v3.

module("luci.controller.shadowsocks", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/shadowsocks") then
		return
	end

	local function has_bin(name)
		return luci.sys.call("command -v %s >/dev/null" %{name}) == 0
	end

	entry({"admin", "services", "shadowsocks"},
		alias("admin", "services", "shadowsocks", "general"),
		_("ShadowSocks"), 10).dependent = true

	entry({"admin", "services", "shadowsocks", "general"},
		cbi("shadowsocks/general"),
		_("General Settings"), 10).leaf = true

	entry({"admin", "services", "shadowsocks", "servers-manage"},
		cbi("shadowsocks/servers-manage"),
		_("Servers Manage"), 20).leaf = true

	if not has_bin("ss-redir") then
		return
	end

	entry({"admin", "services", "shadowsocks", "access-control"},
		cbi("shadowsocks/access-control"),
		_("Access Control"), 30).leaf = true
end
