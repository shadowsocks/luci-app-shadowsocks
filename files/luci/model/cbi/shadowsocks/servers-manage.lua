-- Copyright (C) 2016 Jian Chang <aa65535@live.com>
-- Licensed to the public under the GNU General Public License v3.

local m, s, o
local shadowsocks = "shadowsocks"

m = Map(shadowsocks, "%s - %s" %{translate("ShadowSocks"), translate("Servers Manage")})

-- [[ Servers Manage ]]--
s = m:section(TypedSection, "servers")
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"
s.extedit = luci.dispatcher.build_url("admin/services/shadowsocks/edit-server/%s")
function s.create(...)
    local sid = TypedSection.create(...)
    if sid then
        luci.http.redirect(s.extedit % sid)
        return
    end
end

o = s:option(DummyValue, "alias", translate("Alias"))
function o.cfgvalue(...)
    return Value.cfgvalue(...) or translate("None")
end

o = s:option(DummyValue, "server", translate("Server Address"))
function o.cfgvalue(...)
    return Value.cfgvalue(...) or "?"
end

o = s:option(DummyValue, "server_port", translate("Server Port"))
function o.cfgvalue(...)
    return Value.cfgvalue(...) or "?"
end

o = s:option(DummyValue, "encrypt_method", translate("Encrypt Method"))
function o.cfgvalue(...)
    local v = Value.cfgvalue(...)
    return v and v:upper() or "?"
end

return m
