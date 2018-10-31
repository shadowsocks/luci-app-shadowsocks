-- Copyright (C) 2014-2018 Jian Chang <aa65535@live.com>
-- Licensed to the public under the GNU General Public License v3.

local m, s, o
local shadowsocks = "shadowsocks"
local uci = luci.model.uci.cursor()
local ipkg = require("luci.model.ipkg")
local servers = {}

local function has_bin(name)
	return luci.sys.call("command -v %s >/dev/null" %{name}) == 0
end

local function has_ss_bin()
	return has_bin("ss-redir"), has_bin("ss-local"), has_bin("ss-tunnel")
end

local function has_udp_relay()
	return luci.sys.call("lsmod | grep -q TPROXY && command -v ip >/dev/null") == 0
end

local has_redir, has_local, has_tunnel = has_ss_bin()

if not has_redir and not has_local and not has_tunnel then
	return Map(shadowsocks, "%s - %s" %{translate("ShadowSocks"),
		translate("General Settings")}, '<b style="color:red">shadowsocks-libev binary file not found.</b>')
end

local function is_running(name)
	return luci.sys.call("pidof %s >/dev/null" %{name}) == 0
end

local function get_status(name)
	return is_running(name) and translate("RUNNING") or translate("NOT RUNNING")
end

uci:foreach(shadowsocks, "servers", function(s)
	if s.server and s.server_port then
		servers[#servers+1] = {name = s[".name"], alias = s.alias or "%s:%s" %{s.server, s.server_port}}
	end
end)

m = Map(shadowsocks, "%s - %s" %{translate("ShadowSocks"), translate("General Settings")})
m.template = "shadowsocks/general"

-- [[ Running Status ]]--
s = m:section(TypedSection, "general", translate("Running Status"))
s.anonymous = true

if has_redir then
	o = s:option(DummyValue, "_redir_status", translate("Transparent Proxy"))
	o.value = "<span id=\"_redir_status\">%s</span>" %{get_status("ss-redir")}
	o.rawhtml = true
end

if has_local then
	o = s:option(DummyValue, "_local_status", translate("SOCKS5 Proxy"))
	o.value = "<span id=\"_local_status\">%s</span>" %{get_status("ss-local")}
	o.rawhtml = true
end

if has_tunnel then
	o = s:option(DummyValue, "_tunnel_status", translate("Port Forward"))
	o.value = "<span id=\"_tunnel_status\">%s</span>" %{get_status("ss-tunnel")}
	o.rawhtml = true
end

s = m:section(TypedSection, "general", translate("Global Settings"))
s.anonymous = true

o = s:option(Value, "startup_delay", translate("Startup Delay"))
o:value(0, translate("Not enabled"))
for _, v in ipairs({5, 10, 15, 25, 40}) do
	o:value(v, translatef("%u seconds", v))
end
o.datatype = "uinteger"
o.default = 0
o.rmempty = false

-- [[ Transparent Proxy ]]--
if has_redir then
	s = m:section(TypedSection, "transparent_proxy", translate("Transparent Proxy"))
	s.anonymous = true

	o = s:option(DynamicList, "main_server", translate("Main Server"))
	o:value("nil", translate("Disable"))
	for _, s in ipairs(servers) do o:value(s.name, s.alias) end
	o.default = "nil"
	o.rmempty = false

	o = s:option(ListValue, "udp_relay_server", translate("UDP-Relay Server"))
	if has_udp_relay() then
		o:value("nil", translate("Disable"))
		o:value("same", translate("Same as Main Server"))
		for _, s in ipairs(servers) do o:value(s.name, s.alias) end
	else
		o:value("nil", translate("Unusable - Missing iptables-mod-tproxy or ip"))
	end
	o.default = "nil"
	o.rmempty = false

	o = s:option(Value, "local_port", translate("Local Port"))
	o.datatype = "port"
	o.default = 1234
	o.rmempty = false

	o = s:option(Value, "mtu", translate("Override MTU"))
	o.datatype = "range(296,9200)"
	o.default = 1492
	o.rmempty = false
end

-- [[ SOCKS5 Proxy ]]--
if has_local then
	s = m:section(TypedSection, "socks5_proxy", translate("SOCKS5 Proxy"))
	s.anonymous = true

	o = s:option(DynamicList, "server", translate("Server"))
	o:value("nil", translate("Disable"))
	for _, s in ipairs(servers) do o:value(s.name, s.alias) end
	o.default = "nil"
	o.rmempty = false

	o = s:option(Value, "local_port", translate("Local Port"))
	o.datatype = "port"
	o.default = 1080
	o.rmempty = false

	o = s:option(Value, "mtu", translate("Override MTU"))
	o.datatype = "range(296,9200)"
	o.default = 1492
	o.rmempty = false
end

-- [[ Port Forward ]]--
if has_tunnel then
	s = m:section(TypedSection, "port_forward", translate("Port Forward"))
	s.anonymous = true

	local port_forward_server = s:option(DynamicList, "server", translate("Server"))
	port_forward_server:value("nil", translate("Disable"))
	for _, s in ipairs(servers) do port_forward_server:value(s.name, s.alias) end
	port_forward_server.default = "nil"
	port_forward_server.rmempty = false
	
	local port_forward_port = s:option(Value, "local_port", translate("Local Port"))
	port_forward_port.datatype = "port"
	port_forward_port.default = 5353
	port_forward_port.rmempty = false

	if ipkg.installed("dnsmasq-full") and ipkg.installed("ipset") then
		function port_forward_server.write(self, section, value)
			luci.sys.call("sed -i '/conf-file=\/etc\/dnsmasq-ss-ipset\.conf/d' /etc/dnsmasq.conf")
			for k, v in pairs(value) do
				if uci:get(shadowsocks,v) == "servers" then
					luci.sys.call("echo conf-file=/etc/dnsmasq-ss-ipset.conf >> /etc/dnsmasq.conf")
					break
				end
			end
			if luci.sys.exec("pidof dnsmasq") ~= "" then
				luci.sys.call("/etc/init.d/dnsmasq restart > /dev/null 2>&1 &")
			end
			DynamicList.write(self, section, value)
		end
		function port_forward_port.write(self, section, value)
			Value.write(self, section, value)
			luci.sys.call("ss-rules -p > /dev/null  2>&1 &")
		end
	end

	o = s:option(Value, "destination", translate("Destination"))
	o.datatype="ipaddr"
	o.default = "8.8.8.8"
	o.rmempty = false

	o = s:option(Value, "destination_port", translate("Destination port"))
	o.datatype="port"
	o.default = "53"
	o.rmempty = false

	o = s:option(Value, "mtu", translate("Override MTU"))
	o.datatype = "range(296,9200)"
	o.default = 1492
	o.rmempty = false
end

return m
