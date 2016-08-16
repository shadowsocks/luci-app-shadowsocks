OpenWrt luci for Shadowsocks-libev
===

特性
---

软件包不包含 [shadowsocks-libev][L] 的可执行文件, 
需要用户自行添加 `ss-redir` 和 `ss-tunnel` 到 `$PATH` 中.  
可执行文件可通过安装 [openwrt-shadowsocks][O] 提供的 `shadowsocks-libev` 获得.  

依赖
---

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
                            ├── access-control.lua // LuCI 访问控制
                            └── general.lua        // LuCI 基本设置
```

 1. `ss-redir` 必需  
    init 脚本执行时会先检查 `ss-redir` 是否存在,
    如果存在则使用 `ss-rules` 生成代理转发规则并启动相应的进程,
    否则包括 LuCI 在内的所有功能都将无法使用.

 2. `ss-tunnel` 可选  
    如果检查到存在 `ss-tunnel`, 则可以使用端口转发功能,
    否则此功能将不可用, LuCI 中将不显示对应设置.

注: 默认情况下, `ss-redir` 和 `ss-tunnel` 在以下径下, 都可被正确调用
```
/bin
/sbin
/usr/bin
/usr/sbin
```

编译
---

从 OpenWrt 的 [SDK][S] 编译  
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


  [L]: https://github.com/shadowsocks/shadowsocks-libev
  [O]: https://github.com/shadowsocks/openwrt-shadowsocks
  [S]: http://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
