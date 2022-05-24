-- Copyright (C) 2014-2022 Jian Chang <aa65535@live.com>
-- Licensed to the public under the GNU General Public License v3.

local m, s, o
local shadowsocks = "shadowsocks"
local uci = luci.model.uci.cursor()
local servers = {}
local cores = tonumber(luci.sys.exec("grep 'processor' /proc/cpuinfo | wc -l"))
local _max = math.max(math.min(cores * 2, 128), cores)
local _step = math.ceil(_max / 32)

local function has_bin(name)
	return luci.sys.call("command -v %s >/dev/null" %{name}) == 0
end

local function has_bins()
	return has_bin("ss-redir"), has_bin("ssr-redir"), has_bin("ss-local"), has_bin("ssr-local"), has_bin("ss-tunnel"), has_bin("ssr-tunnel")
end

local function has_udp_relay()
	return luci.sys.call("lsmod | grep -q TPROXY && command -v ip >/dev/null") == 0
end

local has_ss_redir, has_ssr_redir, has_ss_local, has_ssr_local, has_ss_tunnel, has_ssr_tunnel = has_bins()

if not has_ss_redir and not has_ssr_redir and not has_ss_local and not has_ssr_local and not has_ss_tunnel and not has_ssr_tunnel then
	return Map(shadowsocks, "%s - %s" %{translate("ShadowSocks"),
		translate("General Settings")}, '<b style="color:red">shadowsocks-libev binary file not found.</b>')
end

uci:foreach(shadowsocks, "servers", function(s)
	if s.server and s.server_port then
		servers[#servers+1] = {type = s.type or "ss", name = s[".name"], alias = s.alias or "%s:%s" %{s.server, s.server_port}}
	end
end)

m = Map(shadowsocks, "%s - %s" %{translate("ShadowSocks"), translate("General Settings")})
m.template = "shadowsocks/general"

-- [[ Running Status ]]--
s = m:section(TypedSection, "general", translate("Running Status"))
s.anonymous = true

if has_ss_redir or has_ssr_redir then
	o = s:option(DummyValue, "_redir_status", translate("Transparent Proxy"))
	o.value = "<span id=\"_redir_status\">%s</span>" %{translate("Updating...")}
	o.rawhtml = true
end

if has_ss_local or has_ssr_local then
	o = s:option(DummyValue, "_local_status", translate("SOCKS5 Proxy"))
	o.value = "<span id=\"_local_status\">%s</span>" %{translate("Updating...")}
	o.rawhtml = true
end

if has_ss_tunnel or has_ssr_tunnel then
	o = s:option(DummyValue, "_tunnel_status", translate("Port Forward"))
	o.value = "<span id=\"_tunnel_status\">%s</span>" %{translate("Updating...")}
	o.rawhtml = true
end

s = m:section(TypedSection, "general", translate("Global Settings"))
s.anonymous = true

o = s:option(ListValue, "startup_delay", translate("Startup Delay"))
o:value(0, translate("Not enabled"))
for _, v in ipairs({5, 10, 15, 25, 40, 60, 90, 120}) do
	o:value(v, translatef("%u seconds", v))
end
o.datatype = "uinteger"
o.default = 0
o.rmempty = false

-- [[ Transparent Proxy ]]--
if has_ss_redir or has_ssr_redir then
	s = m:section(TypedSection, "transparent_proxy", translate("Transparent Proxy"))
	s.anonymous = true

	o = s:option(ListValue, "main_server", translate("Main Server"))
	o:value("nil", translate("Disable"))
	for _, s in ipairs(servers) do
		if (has_ss_redir and s.type == "ss") or (has_ssr_redir and s.type == "ssr") then
			o:value(s.name, s.alias)
		end
	end
	o.default = "nil"
	o.rmempty = false

	o = s:option(ListValue, "udp_relay_server", translate("UDP-Relay Server"))
	if has_udp_relay() then
		o:value("nil", translate("Disable"))
		o:value("same", translate("Same as Main Server"))
		for _, s in ipairs(servers) do
			if (has_ss_redir and s.type == "ss") or (has_ssr_redir and s.type == "ssr") then
				o:value(s.name, s.alias)
			end
		end
	else
		o:value("nil", translate("Unusable - Missing iptables-mod-tproxy or ip"))
	end
	o.default = "nil"
	o.rmempty = false

	o = s:option(ListValue, "processes", translate("Multiprocessing"))
	for v = 0, _max, _step do
		if v == 0 then
			o:value(0, translatef("Auto(%u processes)", cores))
		else
			o:value(v, translatef("%u processes", v))
		end
	end
	o.datatype = "uinteger"
	o.default = 0
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
if has_ss_local or has_ssr_local then
	s = m:section(TypedSection, "socks5_proxy", translate("SOCKS5 Proxy"))
	s.anonymous = true

	o = s:option(ListValue, "server", translate("Server"))
	o:value("nil", translate("Disable"))
	for _, s in ipairs(servers) do
		if (has_ss_local and s.type == "ss") or (has_ssr_local and s.type == "ssr") then
			o:value(s.name, s.alias)
		end
	end
	o.default = "nil"
	o.rmempty = false

	o = s:option(ListValue, "processes", translate("Multiprocessing"))
	for v = 0, _max, _step do
		if v == 0 then
			o:value(0, translatef("Auto(%u processes)", cores))
		else
			o:value(v, translatef("%u processes", v))
		end
	end
	o.datatype = "uinteger"
	o.default = 0
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
if has_ss_tunnel or has_ssr_tunnel then
	s = m:section(TypedSection, "port_forward", translate("Port Forward"))
	s.anonymous = true

	o = s:option(ListValue, "server", translate("Server"))
	o:value("nil", translate("Disable"))
	for _, s in ipairs(servers) do
		if (has_ss_tunnel and s.type == "ss") or (has_ssr_tunnel and s.type == "ssr") then
			o:value(s.name, s.alias)
		end
	end
	o.default = "nil"
	o.rmempty = false

	o = s:option(ListValue, "processes", translate("Multiprocessing"))
	for v = 0, _max, _step do
		if v == 0 then
			o:value(0, translatef("Auto(%u processes)", cores))
		else
			o:value(v, translatef("%u processes", v))
		end
	end
	o.datatype = "uinteger"
	o.default = 0
	o.rmempty = false

	o = s:option(Value, "local_port", translate("Local Port"))
	o.datatype = "port"
	o.default = 5300
	o.rmempty = false

	o = s:option(Value, "destination", translate("Destination"))
	o.default = "8.8.4.4:53"
	o.rmempty = false

	o = s:option(Value, "mtu", translate("Override MTU"))
	o.datatype = "range(296,9200)"
	o.default = 1492
	o.rmempty = false
end

return m
