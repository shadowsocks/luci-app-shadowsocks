-- Copyright (C) 2016 Jian Chang <aa65535@live.com>
-- Licensed to the public under the GNU General Public License v3.

return {
	name = "shadowsocks",
	uci = luci.model.uci.cursor(),
	has_bin = function (name)
		return luci.sys.call("command -v %s >/dev/null" %{name}) == 0
	end,
	is_running = function (name)
		return luci.sys.call("pidof %s >/dev/null" %{name}) == 0
	end,
}
