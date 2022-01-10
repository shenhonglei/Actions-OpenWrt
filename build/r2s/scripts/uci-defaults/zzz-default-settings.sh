# ipk
opkg install /*_*_*.ipk
rm -f /*_*_*.ipk

# slim 固件本地 opkg 配置
if ls -l /local_feed/*.ipk &>/dev/null;then
    sed -ri 's@^[^#]@#&@' /etc/opkg/distfeeds.conf
    grep -E '/local_feed' /etc/opkg/customfeeds.conf || echo 'src/gz local file:///local_feed' >> /etc/opkg/customfeeds.conf
    # 取消签名，暂时解决不了
    sed -ri '/check_signature/s@^[^#]@#&@' /etc/opkg.conf
fi

if [ -f /etc/uci-defaults/luci-aliyundrive-webdav ];then
    uci set  aliyundrive-webdav.@server[0].enable=0
    uci commit aliyundrive-webdav
fi

# 默认主题
if [ -d /usr/lib/lua/luci/view/themes/argonne/ ];then
    uci set luci.main.mediaurlbase='/luci-static/argonne'
fi
if [ -d /usr/lib/lua/luci/view/themes/argon_blue/ ];then
    uci set luci.main.mediaurlbase='/luci-static/argon_blue'
fi
uci commit luci
# 此文件名注意ls 排序，下面也行
# sed -ri "/option mediaurlbase/s#(/luci-static/)[^']+#\1argon_blue#" /etc/config/luci
# uci commit luci

if [ -f /etc/config/qbittorrent ];then
    uci set qbittorrent.main.AnnounceToAllTrackers='true'
    uci commit qbittorrent
fi

# 允许 wan 访问 openwrt web
# uci set uhttpd.main.rfc1918_filter='0'
# uci commit uhttpd

# 允许 wan ssh
uci delete dropbear.@dropbear[0].Interface
uci commit dropbear
# 配合下面的单个端口，或者放行整个段
# iptables -I input_wan_rule -p tcp -m tcp --dport 22 -j ACCEPT
# 二级路由的话放行上层的  CIDR 即可

if ! grep -Eq 'iptables -I input_wan_rule -s \S+\s+-j ACCEPT' /etc/firewall.user;then
cat >> /etc/firewall.user << EOF
# 允许wan口指定网段访问，一般二级路由下需要
iptables -I input_wan_rule -s 192.168.0.0/16  -j ACCEPT
EOF
fi

# dnsmasq
uci set dhcp.@dnsmasq[0].rebind_protection='0'
uci set dhcp.@dnsmasq[0].localservice='0'
uci set dhcp.@dnsmasq[0].nonwildcard='0'
uci set dhcp.@dnsmasq[0].server='223.5.5.5'
uci commit dhcp
