-- Copyright (C) 2016-2022 Jian Chang <aa65535@live.com>
-- Licensed to the public under the GNU General Public License v3.

local m, s, o
local shadowsocks = "shadowsocks"
local sid = arg[1]
local encrypt_methods = {
	"none",
	"table",
	"rc4",
	"rc4-md5",
	"aes-128-cfb",
	"aes-192-cfb",
	"aes-256-cfb",
	"aes-128-ctr",
	"aes-192-ctr",
	"aes-256-ctr",
	"aes-128-gcm",
	"aes-192-gcm",
	"aes-256-gcm",
	"camellia-128-cfb",
	"camellia-192-cfb",
	"camellia-256-cfb",
	"bf-cfb",
	"salsa20",
	"chacha20",
	"chacha20-ietf",
	"chacha20-ietf-poly1305",
	"xchacha20-ietf-poly1305",
}

local protocols = {
	"origin",
	"auth_sha1",
	"auth_sha1_v2",
	"auth_sha1_v4",
	"auth_aes128_md5",
	"auth_aes128_sha1",
	"auth_chain_a",
	"auth_chain_b",
	"auth_chain_c",
	"auth_chain_d",
	"auth_chain_e",
	"auth_chain_f",
}

local obfss = {
	"plain",
	"http_simple",
	"http_post",
	"tls1.2_ticket_auth",
}

local function has_bin(name)
	return luci.sys.call("command -v %s >/dev/null" %{name}) == 0
end

local function has_ss_bins()
	return has_bin("ss-redir") or has_bin("ss-local") or has_bin("ss-tunnel")
end

local function has_ssr_bins()
	return has_bin("ssr-redir") or has_bin("ssr-local") or has_bin("ssr-tunnel")
end

local function support_fast_open()
	local nixio = require "nixio"
	local bit = tonumber(luci.sys.exec("cat /proc/sys/net/ipv4/tcp_fastopen 2>/dev/null"):trim()) or 0
	return nixio.bit.band(bit, 1) == 1
end

m = Map(shadowsocks, "%s - %s" %{translate("ShadowSocks"), translate("Edit Server")})
m.redirect = luci.dispatcher.build_url("admin/services/shadowsocks/servers")
m.sid = sid
m.template = "shadowsocks/servers-details"

if m.uci:get(shadowsocks, sid) ~= "servers" then
	luci.http.redirect(m.redirect)
	return
end

-- [[ Edit Server ]]--
s = m:section(NamedSection, sid, "servers")
s.anonymous = true
s.addremove = false

o = s:option(Value, "alias", translate("Alias(optional)"))
o.rmempty = true

o = s:option(Value, "group", translate("Group Name"))
o.default = "Default"
o.rmempty = true

o = s:option(ListValue, "type", translate("Server Type"))
if has_ss_bins() then o:value("ss", "Shadowsocks") end
if has_ssr_bins() then o:value("ssr", "ShadowsocksR") end
o.default = "ss"
o.rmempty = false

if support_fast_open() then
	o = s:option(Flag, "fast_open", translate("TCP Fast Open"))
	o.rmempty = false
end

o = s:option(Flag, "no_delay", translate("TCP no-delay"))
o:depends("type", "ss")
o.rmempty = false

o = s:option(Value, "host", translate("Server Host"))
o.datatype = "host"
o.rmempty = true

o = s:option(Value, "server", translate("Server Address"))
o.datatype = "ipaddr"
o.rmempty = false

o = s:option(Value, "server_port", translate("Server Port"))
o.datatype = "port"
o.rmempty = false

o = s:option(Value, "timeout", translate("Connection Timeout"))
o.datatype = "uinteger"
o.default = 60
o.rmempty = false

o = s:option(Value, "password", translate("Password"))
o.password = true

o = s:option(Value, "key", translate("Directly Key"))
o:depends("type", "ss")

o = s:option(ListValue, "encrypt_method", translate("Encrypt Method"))
for _, v in ipairs(encrypt_methods) do o:value(v, v:upper()) end
o.rmempty = false

o = s:option(Value, "plugin", translate("Plugin Name"))
o.placeholder = "eg: obfs-local"
o:depends("type", "ss")

o = s:option(Value, "plugin_opts", translate("Plugin Arguments"))
o.placeholder = "eg: obfs=http;obfs-host=www.bing.com"
o:depends("type", "ss")

o = s:option(ListValue, "protocol", translate("Protocol"))
for _, v in ipairs(protocols) do o:value(v, v:upper()) end
o:depends("type", "ssr")
o.rmempty = false

o = s:option(Value, "protocol_param", translate("Protocol Param"))
o:depends("type", "ssr")
o.rmempty = true

o = s:option(ListValue, "obfs", translate("Obfuscation"))
for _, v in ipairs(obfss) do o:value(v, v:upper()) end
o:depends("type", "ssr")
o.rmempty = false

o = s:option(Value, "obfs_param", translate("Obfuscation Param"))
o:depends("type", "ssr")
o.rmempty = true

return m
