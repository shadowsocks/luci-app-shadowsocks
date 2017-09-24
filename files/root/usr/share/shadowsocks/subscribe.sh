#!/bin/bash
# Copyright (C) 2017 XiaoShan https://www.mivm.cn

# 检查是否为 IP 地址
CheckIPAddr() {
    echo $1 | grep "^[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}[0-9]\{1,3\}$" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo 1
        return
    fi
    local ipaddr=($(echo $1 | sed 's/\./ /g'))
    [ ${#ipaddr[@]} -ne 4 ] && echo 1 && return
    for ((i=0;i<${#ipaddr[@]};i++))
    do
        [ ${ipaddr[i]} -gt 255 -a ${ipaddr[i]} -lt 0 ] && echo 1 && return
    done
    echo 0
    return
}

# URL 安全的 base64 解码
urlsafe_b64decode() {
    local d="====" data=$(echo $1 | sed 's/_/\//g; s/-/+/g')
    local mod4=$((${#data}%4))
    [ $mod4 -gt 0 ] && data=${data}${d:mod4}
    echo $data | base64 -d
}

# 添加/更新 服务器信息
Server_Update() {
    local uci_set="uci -q set shadowsocks.@servers[$1]."
    ${uci_set}alias="[$ssr_group] $ssr_remarks"
    ${uci_set}server="$ssr_host"
    ${uci_set}server_port="$ssr_port"
    ${uci_set}password="$ssr_passwd"
    uci -q get shadowsocks.@servers[$1].timeout >/dev/null || ${uci_set}timeout="60"
    ${uci_set}encrypt_method="$ssr_method"
    ${uci_set}protocol="$ssr_protocol"
    ${uci_set}protocol_param="$ssr_protoparam"
    ${uci_set}obfs="$ssr_obfs"
    ${uci_set}obfs_param="$ssr_obfsparam"
}

subscribe_url=($(uci get shadowsocks.@server_subscribe[0].subscribe_url)) # 获取订阅链接列表
[ ${#subscribe_url[@]} -eq 0 ] && exit 1
[ $(uci -q get shadowsocks.@server_subscribe[0].proxy || echo 0) -eq 0 ] && /etc/init.d/shadowsocks stop >/dev/null 2>&1
for ((o=0;o<${#subscribe_url[@]};o++))
do
    subscribe_data=$(curl -s -L --connect-timeout 3 ${subscribe_url[o]})
    curl_code=$?
    if [ $curl_code -eq 0 ];then # curl 返回代码为非 0 即获取失败
        ssr_url=($(echo $subscribe_data | base64 -d | sed 's/\r//g')) # 解码订阅数据并删除 \r 换行符
        # echo ${ssr_url[*]}
        # exit
        subscribe_max=$(echo ${ssr_url[0]} | grep -i MAX= | awk -F = '{print $2}') # 获取 MAX 随机值
        subscribe_max_x=()
        if [ -n "$subscribe_max" ]; then
            while [ ${#subscribe_max_x[@]} -ne $subscribe_max ]
            do
                if [ ${#ssr_url[@]} -ge 10 ]; then # 链接数量如果大于 10 有几率获取两位的随机数
                    if [ $(($(head -n 256 /dev/urandom | tr -dc "123456789" | head -c3)%2)) -eq 1 ]; then # 获取随机数并求2的余数，不等于1获取两位数
                        temp_x=$(head -n 256 /dev/urandom | tr -dc "123456789" | head -c1)
                    else
                        temp_x=$(head -n 256 /dev/urandom | tr -dc "123456789" | head -c2)
                    fi
                else
                    temp_x=$(head -n 256 /dev/urandom | tr -dc "123456789" | head -c1)
                fi
                [ $temp_x -lt ${#ssr_url[@]} -a -z "$(echo "${subscribe_max_x[*]}" | grep -w ${temp_x})" ] && subscribe_max_x[${#subscribe_max_x[@]}]="$temp_x" # 判断获取的随机数是否大于链接数 是否重复
            done
        else
            subscribe_max=${#ssr_url[@]}
        fi
        ssr_group=$(urlsafe_b64decode $(urlsafe_b64decode ${ssr_url[$((${#ssr_url[@]} - 1))]//ssr:\/\//} | sed 's/&/\n/g' | grep group= | awk -F = '{print $2}'))
        if [ -n "$ssr_group" ]; then
            subscribe_i=0
            subscribe_n=0
            subscribe_o=0
            subscribe_x=""
            temp_host_o=()
            curr_ssr=$(uci show shadowsocks | grep @servers | grep -c server=)
            for ((x=0;x<$curr_ssr;x++)) # 循环已有服务器信息，匹配当前订阅群组
            do
                temp_alias=$(uci -q get shadowsocks.@servers[$x].alias | grep "\[$ssr_group\]")
                [ -n "$temp_alias" ] && temp_host_o[${#temp_host_o[@]}]=$(uci get shadowsocks.@servers[$x].server)
            done
            for ((x=0;x<$subscribe_max;x++)) # 循环链接
            do
                if [ ${#subscribe_max_x[@]} -eq 0 ]; then
                    temp_x=$x
                else
                    temp_x=${subscribe_max_x[x]}
                fi
                temp_info=$(urlsafe_b64decode ${ssr_url[temp_x]//ssr:\/\//}) # 解码 SSR 链接
                # 依次获取基本信息
                info=${temp_info///?*/}
                temp_info_array=(${info//:/ })
                ssr_host=${temp_info_array[0]}
                ssr_port=${temp_info_array[1]}
                ssr_protocol=${temp_info_array[2]}
                ssr_method=${temp_info_array[3]}
                ssr_obfs=${temp_info_array[4]}
                ssr_passwd=$(urlsafe_b64decode ${temp_info_array[5]})
                info=${temp_info:$((${#info} + 2))}
                info=(${info//&/ })
                ssr_protoparam=""
                ssr_obfsparam=""
                ssr_remarks="$temp_x"
                for ((i=0;i<${#info[@]};i++)) # 循环扩展信息
                do
                    temp_info=($(echo ${info[i]} | sed 's/=/ /g'))
                    case "${temp_info[0]}" in
                        protoparam)
                            ssr_protoparam=$(urlsafe_b64decode ${temp_info[1]})
                        ;;
                        obfsparam)
                            ssr_obfsparam=$(urlsafe_b64decode ${temp_info[1]})
                        ;;
                        remarks)
                            ssr_remarks=$(urlsafe_b64decode ${temp_info[1]})
                        ;;
                    esac
                done
                [ $(CheckIPAddr $ssr_host) -eq 1 ] && ssr_host=$(nslookup $ssr_host | grep "Address 1" | awk '{print $3}') && [ -z "$ssr_host" ] && continue # 使用 nslookup 解析域名并获取 IP
                uci_s=$(uci show shadowsocks | grep @servers | grep server= | grep -n -w $ssr_host )
                if [ -n "$uci_s" ]; then # 判断当前服务器信息是否存在
                    uci_x=$((${uci_s//:*/} - 1))
                else
                    uci_x=$(uci show shadowsocks | grep -c =servers)
                    uci add shadowsocks servers >/dev/null 2>&1
                    subscribe_n=$(($subscribe_n + 1))
                fi
                Server_Update $uci_x
                subscribe_x=${subscribe_x}$ssr_host" "

                # echo "服务器地址: $ssr_host"
                # echo "服务器端口 $ssr_port"
                # echo "密码: $ssr_passwd"
                # echo "加密: $ssr_method"
                # echo "协议: $ssr_protocol"
                # echo "协议参数: $ssr_protoparam"
                # echo "混淆: $ssr_obfs"
                # echo "混淆参数: $ssr_obfsparam"
                # echo "备注: $ssr_remarks"
            done
            for ((x=0;x<${#temp_host_o[@]};x++)) # 新旧服务器信息匹配，旧服务器不存在则删除
            do
                if [ -z "$(echo "$subscribe_x" | grep -w ${temp_host_o[x]})" ]; then
                    temp_host_x=$(uci show shadowsocks | grep @servers | grep server= | grep -n ${temp_host_o[x]})
                    uci del shadowsocks.@servers[$((${temp_host_x//:*/}-1))]
                    subscribe_o=$(($subscribe_o + 1))
                fi
            done
            subscribe_log="$ssr_group 服务器订阅更新成功 服务器数量: ${#ssr_url[@]} 新增服务器: $subscribe_n 删除服务器: $subscribe_o"
            [ ${#subscribe_max_x[@]} -ne 0 ] && subscribe_log="$subscribe_log 随机获取: ${#subscribe_max_x[@]}"
            logger -st shadowsocks_subscribe[$$] -p6 "$subscribe_log"
            uci commit shadowsocks
        else
            logger -st shadowsocks_subscribe[$$] -p3 "${subscribe_url[$o]} 订阅文件解析失败 无法获取 Group"
        fi
        rm -rf /tmp/shadowsocks_subscribe.txt
    else
        logger -st shadowsocks_subscribe[$$] -p3 "${subscribe_url[$o]} 订阅文件获取失败 错误代码: $curl_code"
    fi
done
/etc/init.d/shadowsocks restart >/dev/null 2>&1
