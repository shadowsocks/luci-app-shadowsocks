OpenWrt LuCI for Shadowsocks-libev
===

[![Download][badge]][download]

特性
---

本软件包是 [shadowsocks-libev][ssl] 的 LuCI 控制界面,
方便用户控制和使用「透明代理」「SOCKS5 代理」「端口转发」功能.  
软件包不显式依赖 `shadowsocks-libev`, 会根据用户添加的可执行文件启用相应的功能,
详情请参考本说明的[依赖](#依赖)部分.  
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

软件包是文件级依赖, 当文件存在时, 相应的功能可被使用, LuCI 界面也会显示相应的设置.  
如果文件不存在, 则对应的功能不可用, LuCI 界面的响应设置也会隐藏.  
以下三个可执行文件都是可选的, 但是需要至少提供一个.

 1. `ss-redir`  
    透明代理功能, 支持 TCP 协议, 安装 `iptables-mod-tproxy` 后可启用
    UDP 协议(UDP 协议需要服务器支持).  
    透明代理启动后会使用 [ss-rules][ssr] 生成代理转发规则并支持访问控制设置.

 2. `ss-local`  
    SOCKS5 代理功能, 支持 TCP 和 UDP 协议(UDP 协议需要服务器支持).

 3. `ss-tunnel`  
    端口转发功能, 支持 TCP 和 UDP 协议(UDP 协议需要服务器支持).

注: 默认情况下, 可执行文件在以下径中, 都可被正确调用
```
/bin
/sbin
/usr/bin
/usr/sbin
```

配置
---

软件包的配置文件路径: `/etc/config/shadowsocks`  
此文件为 UCI 配置文件, 配置方式可参考 [Wiki][uus] 和 [OpenWrt Wiki][uci]  
启用「透明代理」功能后, 软件包提供了灵活强大的访问控制功能, 设置可参考 [Wiki][lac]  

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
 [uus]: https://github.com/shadowsocks/luci-app-shadowsocks/wiki/Use-UCI-system
 [uci]: https://wiki.openwrt.org/doc/uci
 [lac]: https://github.com/shadowsocks/luci-app-shadowsocks/wiki/LuCI-Access-Control
