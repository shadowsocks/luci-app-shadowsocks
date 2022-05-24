-- Copyright (C) 2014-2022 Jian Chang <aa65535@live.com>
-- Licensed to the public under the GNU General Public License v3.

module("luci.controller.shadowsocks", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/shadowsocks") then
		return
	end

	local page

	page = entry({"admin", "services", "shadowsocks"},
		alias("admin", "services", "shadowsocks", "general"),
		_("ShadowSocks"), 10)
	page.dependent = true
	page.acl_depends = { "luci-app-shadowsocks" }

	page = entry({"admin", "services", "shadowsocks", "general"},
		cbi("shadowsocks/general"),
		_("General Settings"), 10)
	page.leaf = true
	page.acl_depends = { "luci-app-shadowsocks" }

	page = entry({"admin", "services", "shadowsocks", "status"},
		call("action_status"))
	page.leaf = true
	page.acl_depends = { "luci-app-shadowsocks" }

	page = entry({"admin", "services", "shadowsocks", "subscription"},
		cbi("shadowsocks/subscription"),
		_("Subscription Manage"), 15)
	page.leaf = true
	page.acl_depends = { "luci-app-shadowsocks" }

	page = entry({"admin", "services", "shadowsocks", "subscribe"},
		call("action_subscribe"))
	page.leaf = true
	page.acl_depends = { "luci-app-shadowsocks" }

	page = entry({"admin", "services", "shadowsocks", "servers"},
		arcombine(cbi("shadowsocks/servers"), cbi("shadowsocks/servers-details")),
		_("Servers Manage"), 20)
	page.leaf = true
	page.acl_depends = { "luci-app-shadowsocks" }

	if luci.sys.call("command -v ss-redir >/dev/null") ~= 0
		and luci.sys.call("command -v ssr-redir >/dev/null") ~= 0 then
		return
	end

	page = entry({"admin", "services", "shadowsocks", "access-control"},
		cbi("shadowsocks/access-control"),
		_("Access Control"), 30)
	page.leaf = true
	page.acl_depends = { "luci-app-shadowsocks" }
end

function action_status()
	local util = require "luci.util"
	local list = util.ubus("service", "list", {name = "shadowsocks"})
	luci.http.prepare_content("application/json")
	luci.http.write_json(list)
end

function action_subscribe()
	local section = luci.http.formvalue("section")
	local code = luci.sys.call("/usr/bin/lua /usr/bin/ss-subscribe %s >/tmp/sub.log" %{section})
	luci.http.prepare_content("application/json")
	luci.http.write_json({code = code})
end
