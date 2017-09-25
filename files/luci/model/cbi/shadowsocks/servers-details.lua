-- Copyright (C) 2016-2017 Jian Chang <aa65535@live.com>
-- Licensed to the public under the GNU General Public License v3.

local m, s, o
local shadowsocks = "shadowsocks"
local sid = arg[1]
local encrypt_methods = {
	"none",
	"table",
	"rc4",
	"rc4-md5",
	"rc4-md5-6",
	"aes-128-cfb",
	"aes-192-cfb",
	"aes-256-cfb",
	"aes-128-ctr",
	"aes-192-ctr",
	"aes-256-ctr",
	"camellia-128-cfb",
	"camellia-192-cfb",
	"camellia-256-cfb",
	"bf-cfb",
	"salsa20",
	"chacha20",
	"chacha20-ietf",
}

local protocols = {
	"origin",
	"verify_simple",
	"verify_sha1",
	"auth_sha1",
	"auth_sha1_v2",	
	"auth_sha1_v4",
	"auth_aes128_md5",
	"auth_aes128_sha1",
	"auth_chain_a",
}

local obfss = {
	"plain",
	"http_simple",
	"http_post",
	"tls_simple",
	"tls1.2_ticket_auth",
}

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

o = s:option(Flag, "fast_open", translate("TCP Fast Open"))
o.rmempty = false

-- o = s:option(Flag, "no_delay", translate("TCP no-delay"))
-- o.rmempty = false

o = s:option(Value, "server", translate("Server Address"))
o.placeholder = "eg: 192.168.1.1"
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

-- o = s:option(Value, "key", translate("Directly Key"))

o = s:option(ListValue, "encrypt_method", translate("Encrypt Method"))
for _, v in ipairs(encrypt_methods) do o:value(v, v:upper()) end
o.rmempty = false

-- o = s:option(Value, "plugin", translate("Plugin Name"))
-- o.placeholder = "eg: obfs-local"

-- o = s:option(Value, "plugin_opts", translate("Plugin Arguments"))
-- o.placeholder = "eg: obfs=http;obfs-host=www.bing.com"

o = s:option(ListValue, "protocol", translate("Protocol"))
for _, v in ipairs(protocols) do o:value(v, v:upper()) end
o.rmempty = false

o = s:option(Value, "protocol_param", translate("Protocol Param"))
o.datatype = "uinteger"
o.rmempty = true

o = s:option(ListValue, "obfs", translate("Obfs"))
for _, v in ipairs(obfss) do o:value(v, v:upper()) end
o.rmempty = false

o = s:option(Value, "obfs_param", translate("Obfs Param"))
o.datatype = "host"
o.rmempty = true

return m
