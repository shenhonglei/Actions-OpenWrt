# adh 提前下载
if grep -Eq '^CONFIG_PACKAGE_luci-app-adguardhome=y' .config;then
    mkdir -p files/root/
    wget https://static.adguard.com/adguardhome/release/AdGuardHome_linux_arm64.tar.gz -O - | \
        tar -zxvf -  --strip-components 2 \
         -C files/root/ ./AdGuardHome/AdGuardHome
    chmod a+x files/root/AdGuardHome

cat > files/root/adh.sh<< 'EOF'
# 安装到 emcc 后进系统执行此脚本
ADH_BIN=$(uci -q get AdGuardHome.AdGuardHome.binpath)
if [ -n ${ADH_BIN} ] && [ -f /root/AdGuardHome ];then
    if [ -L ${ADH_BIN} ];then
        ADH_BIN_PATH=$(readlink -f ${ADH_BIN})
        mkdir -p ${ADH_BIN_PATH}
        uci -q set AdGuardHome.AdGuardHome.binpath="${ADH_BIN_PATH}/AdGuardHome"
        uci commit AdGuardHome
    fi
    cp /root/AdGuardHome ${ADH_BIN}
fi
EOF

fi