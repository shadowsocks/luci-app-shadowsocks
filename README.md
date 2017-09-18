OpenWrt LuCI for ShadowsocksR-libev
===

简介
---

本软件包是 [ShadowsocksR-libev][openwrt-shadowsocks] 的 LuCI 控制界面,
方便用户控制和使用「透明代理」「SOCKS5 代理」「端口转发」功能.  
附加功能：服务器订阅、DNS 污染、GFW 模式。

编译
---

从 OpenWrt 的 [SDK][openwrt-sdk] 编译  
```bash
# 解压下载好的 SDK
tar xjf OpenWrt-SDK-ar71xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2.tar.bz2
cd OpenWrt-SDK-ar71xx-*
# Clone 项目
git clone https://github.com/Hill-98/luci-app-shadowsocks.git package/luci-app-shadowsocks
# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/luci-app-shadowsocks/tools/po2lmo
make && sudo make install
popd
# 选择要编译的包 LuCI -> 3. Applications
make menuconfig
# 开始编译
make package/luci-app-shadowsocks/compile V=99
```

 [openwrt-shadowsocks]: https://github.com/Hill-98/shadowsocksr-libev_openwrt
 [openwrt-sdk]: https://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
