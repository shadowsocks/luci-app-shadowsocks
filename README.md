OpenWrt LuCI for Shadowsocks-libev
===

[![Download][badge]][download]

特性
---

软件包不包含 [shadowsocks-libev][ssl] 的可执行文件,
需要用户自行添加 `ss-redir`, `ss-local` 和 `ss-tunnel` 到 `$PATH` 中.  
可执行文件可通过安装 [openwrt-shadowsocks][oss] 提供的 `shadowsocks-libev` 获得.  

软件包文件结构:
```
/
├── etc/
│   ├── config/
│   │   └── shadowsocks                            // UCI 配置文件
│   └── init.d/
│       └── shadowsocks                            // init 脚本
└── usr/
    ├── bin/
    │   └── ss-rules                               // 生成代理转发规则的脚本
    └── lib/
        └── lua/
            └── luci/                              // LuCI 部分
                ├── controller/
                │   └── shadowsocks.lua            // LuCI 菜单配置
                ├── i18n/                          // LuCI 语言文件
                │   └── shadowsocks.zh-cn.lmo
                └── model/
                    └── cbi/
                        └── shadowsocks/
                            ├── general.lua        // LuCI 基本设置
                            ├── servers-manage.lua // LuCI 服务器管理
                            └── access-control.lua // LuCI 访问控制
```

依赖
---

 1. `ss-redir` 可选  
    如果存在, 则可以使用透明代理功能并使用 [ss-rules][ssr] 生成代理转发规则,
    同时支持访问控制设置,
    否则此功能将不可用, LuCI 中将不显示对应设置和访问控制.

 2. `ss-local` 可选  
    如果存在, 则可以使用 SOCKS5 代理功能, 否则此功能将不可用, LuCI 中将不显示对应设置.

 3. `ss-tunnel` 可选  
    如果存在, 则可以使用端口转发功能, 否则此功能将不可用, LuCI 中将不显示对应设置.

注: 默认情况下, `ss-redir`, `ss-local` 和 `ss-tunnel` 在以下径下, 都可被正确调用
```
/bin
/sbin
/usr/bin
/usr/sbin
```

配置
---

配置文件路径: `/etc/config/shadowsocks`  
此文件为 UCI 配置文件, 配置方式可参考 [Wiki][uus] 和 [OpenWrt Wiki][uci]  
LuCI 的访问控制设置可以参考 [Wiki][lac]  

编译
---

从 OpenWrt 的 [SDK][sdk] 编译  
```bash
# 解压下载好的 SDK
tar xjf OpenWrt-SDK-ar71xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2.tar.bz2
cd OpenWrt-SDK-ar71xx-*
# Clone 项目
git clone https://github.com/shadowsocks/luci-app-shadowsocks.git package/luci-app-shadowsocks
# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/luci-app-shadowsocks/tools/po2lmo
make && sudo make install
popd
# 选择要编译的包 LuCI -> 3. Applications
make menuconfig
# 开始编译
make package/luci-app-shadowsocks/compile V=99
```


  [ssl]: https://github.com/shadowsocks/shadowsocks-libev
  [oss]: https://github.com/shadowsocks/openwrt-shadowsocks
  [sdk]: http://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
  [badge]: https://api.bintray.com/packages/aa65535/opkg/luci-app-shadowsocks/images/download.svg
  [download]: https://bintray.com/aa65535/opkg/luci-app-shadowsocks/_latestVersion
  [ssr]: https://github.com/shadowsocks/luci-app-shadowsocks/wiki/Instruction-of-ss-rules
  [uus]: https://github.com/shadowsocks/openwrt-shadowsocks/wiki/Use-UCI-system
  [uci]: https://wiki.openwrt.org/doc/uci
  [lac]: https://github.com/shadowsocks/luci-app-shadowsocks/wiki/LuCI-Access-Control
