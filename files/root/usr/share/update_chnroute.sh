#!/bin/sh
wget -t 3 -T 5 -qO /tmp/delegated-apnic-latest http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest
[ $? -eq 0 ] && {
    cat /tmp/delegated-apnic-latest | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /etc/shadowsocks/china_chnroute.txt
    /etc/init.d/shadowsocks restart
}