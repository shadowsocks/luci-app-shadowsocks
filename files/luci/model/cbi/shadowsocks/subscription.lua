-- Copyright (C) 2021 Jian Chang <aa65535@live.com>
-- Licensed to the public under the GNU General Public License v3.

local m, s, o, u
local shadowsocks = "shadowsocks"

m = Map(shadowsocks, "%s - %s" %{translate("ShadowSocks"), translate("Subscription Manage")})

s = m:section(TypedSection, "subscription", translate("Subscription Manage"))
s.addremove = true
s.anonymous = true

o = s:option(Value, "name", translate("Subscription Name"))
o.rmempty = false

u = s:option(Value, "subscription_url", translate("Subscription URL"))
u.rmempty = false

o = s:option(Value, "filter_words", translate("Filter Words"))
o.description = translate("Splited by <code style='color:red'>/</code>. Server whose alias contain the above string will be filtered.")
o.rmempty = true

o = s:option(Flag, "auto_update", translate("Auto Update"))
o.default = "1"
o.rmempty = false

o = s:option(ListValue, "update_hour", translate("Update Hour"))
for t = 0, 23 do o:value("%02d" %{t}, "%02d" %{t}) end
o.default = 6
o.rmempty = false

o = s:option(Button, "subscribe", translate("Update Now"))
o.rawhtml = true
o.template = "shadowsocks/subscribe"
o.url = u

return m
