LuCI interface for Shadowsocks-libev
===

特性
---

软件包不包含 [shadowsocks-libev][L] 的可执行文件, 需要用户自行添加 `ss-redir` 和 `ss-tunnel` 到 `$PATH` 中, 软件启动时会自动调用以上两个可执行文件.  

编译
---
 > 从 OpenWrt 的 [SDK][S] 编译  

```bash
# 解压下载好的 SDK
tar xjf OpenWrt-SDK-ar71xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2.tar.bz2
cd OpenWrt-SDK-ar71xx-*
# Clone 项目
git clone https://github.com/aa65535/luci-app-shadowsocks.git package/luci-app-shadowsocks
# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/luci-app-shadowsocks/tools/po2lmo
make && sudo make install
popd
# 选择要编译的包 LuCI -> 3. Applications
make menuconfig
# 开始编译
make package/luci-app-shadowsocks/compile V=99
```


  [L]: https://github.com/shadowsocks/shadowsocks-libev
  [S]: http://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
