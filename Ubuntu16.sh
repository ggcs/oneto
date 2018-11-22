#!/bin/bash
#授权chmod +x Ubuntu16.sh
#################################################
#   Ubuntu16初始化脚本
#   
# wget -O Ubuntu16.sh https://raw.githubusercontent.com/IloveJFla/oneto/master/Ubuntu16.sh && chmod a+x Ubuntu16.sh && bash Ubuntu16.sh
#   
#################################################
#
Green_font="\033[32m" && Yellow_font="\033[33m" && Red_font="\033[31m" && Font_suffix="\033[0m"
Info="${Green_font}[Info]${Font_suffix}"
Error="${Red_font}[Error]${Font_suffix}"
reboot="${Yellow_font}重启${Font_suffix}"
echo -e "${Green_font}
#================================================
#              Ubuntu初始化脚本
#            2018-11-22 21:03
#================================================
${Font_suffix}"

check_sys(){
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
    elif cat /etc/issue | grep -q -E -i "debian"; then
        release="debian"
    elif cat /etc/issue | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    elif cat /proc/version | grep -q -E -i "debian"; then
        release="debian"
    elif cat /proc/version | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    fi
}

check_system(){
check_sys
[[ ${release} != "ubuntu" ]]  && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
}

check_root(){
    [[ "`id -u`" != "0" ]] && echo -e "${Error} must be root user !" && exit 1
}

check_kvm(){
    [[ -d "/proc/vz" ]] && echo -e "${red}Error:${plain} Your VPS is based on OpenVZ, which is not supported." && exit 1
}




initialization(){

check_system
check_root
check_kvm

resize2fs /dev/vda1


# echo '
# nameserver 8.8.8.8
# nameserver 8.8.4.4
# nameserver 2001:4860:4860::8888
# nameserver 2001:4860:4860::8844
# ' > /etc/resolv.conf
# sudo service networking restart

rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(($RANDOM+1000000000)) #增加一个10位的数再求余
    echo $(($num%$max+$min))
}

rnd=$(rand 40000 50000)

# echo "重新连接的端口号为$rnd"
# exit 1

sed -i "s/Port .*/Port $rnd/g" /etc/ssh/sshd_config && service ssh restart



sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install screen nano make htop speedometer wget git zip -y

sudo apt install vnstat vnstati -y
ip_ver=$(ip route show|grep "default"|awk '{print $5}')
vnstat -u -i ${ip_ver}
sed -i "s/eth0/${ip_ver}/" /etc/vnstat.conf
systemctl stop vnstat
chown vnstat:vnstat /var/lib/vnstat/.${ip_ver}
chown vnstat:vnstat /var/lib/vnstat/${ip_ver}
systemctl start vnstat

#编译安装aria2
apt-get -y install build-essential
apt-get -y install software-properties-common
add-apt-repository ppa:ubuntu-toolchain-r/test -y
apt-get update -y
apt-get -y install make gcc-6 g++6

sudo apt-get install gcc-6 g++-6 -y && \
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6 && \
sudo update-alternatives --config gcc

apt-get install -y libcurl4-openssl-dev libevent-dev ca-certificates pkg-config build-essential intltool libgcrypt-dev libssl-dev libxml2-dev
apt-get install -y libssl-dev libgcrypt-dev libssh2-1-dev libc-ares-dev libexpat1-dev zlib1g-dev libsqlite3-dev pkg-config

wget --no-check-certificate https://github.com/aria2/aria2/releases/download/release-1.34.0/aria2-1.34.0.tar.gz
tar zxf aria2-1.34.0.tar.gz
cd ./aria2-1.34.0
./configure
make
make install
cd

apt-get install fuse unzip -y
wget https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip
cd rclone-*-linux-amd64
sudo cp rclone /usr/bin/
sudo chown root:root /usr/bin/rclone
sudo chmod 755 /usr/bin/rclone
sudo mkdir -p /usr/local/share/man/man1
sudo cp rclone.1 /usr/local/share/man/man1/
sudo mandb 
cd

sudo apt-get autoclean
sudo apt-get clean
sudo apt-get autoremove
clear

aria2c -v
rclone -V 


echo -e "${Info} vnstat rclone htop speedometer aria2安装成功！, 重新连接的端口号为$rnd"

}

BBRinstall(){

apt install --install-recommends linux-generic-hwe-16.04 -y

echo -e "${Info} 确认内核安装无误后, ${reboot}你的VPS, 开机后再次运行该脚本的第二项！"

    read -e -p "是否现在重启 ? [Y/n] :" yn
    [[ -z "${yn}" ]] && yn="y"
    if [[ $yn == [Yy] ]]; then
        echo -e "${Info} VPS 重启中..."
        reboot
    fi
}
BBRstart(){
check_system
check_root
check_kvm

remove_all
sudo modprobe tcp_bbr
echo "tcp_bbr" | sudo tee --append /etc/modules-load.d/modules.conf
echo "net.core.default_qdisc=fq" | sudo tee --append /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee --append /etc/sysctl.conf
sysctl -p
clear
sysctl net.ipv4.tcp_available_congestion_control
sysctl net.ipv4.tcp_congestion_control
echo -e "${Info}BBR启动成功！"
}

MBBRinstall(){
check_system
check_root
check_kvm


wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.10.1/linux-headers-4.10.1-041001-generic_4.10.1-041001.201702260735_amd64.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.10.1/linux-headers-4.10.1-041001_4.10.1-041001.201702260735_all.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.10.1/linux-image-4.10.1-041001-generic_4.10.1-041001.201702260735_amd64.deb


dpkg -i linux-image-4.10.1-041001-generic_4.10.1-041001.201702260735_amd64.deb
dpkg -i linux-headers-4.10.1-041001_4.10.1-041001.201702260735_all.deb
dpkg -i linux-headers-4.10.1-041001-generic_4.10.1-041001.201702260735_amd64.deb
# update-grub

    detele_kernel
    BBR_grub

echo -e "${Info} 确认内核安装无误后, ${reboot}你的VPS, 开机后再次运行该脚本的启用魔改BBR"

    read -e -p "是否现在重启 ? [Y/n] :" yn
    [[ -z "${yn}" ]] && yn="y"
    if [[ $yn == [Yy] ]]; then
        echo -e "${Info} VPS 重启中..."
        reboot
    fi
}


MBBRstart(){
remove_all
apt-get update -y
apt-get -y install build-essential
apt-get -y install software-properties-common
add-apt-repository ppa:ubuntu-toolchain-r/test -y
apt-get update -y
apt-get -y install make gcc-6

# mkdir bbrmod && cd bbrmod
# wget -N --no-check-certificate https://raw.githubusercontent.com/IloveJFla/oneto/master/BBRnanqinlang/tcp_nanqinlang.c
# echo "obj-m := tcp_nanqinlang.o" > Makefile
# make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc-6
# install tcp_nanqinlang.ko /lib/modules/$(uname -r)/kernel
# cp -rf ./tcp_nanqinlang.ko /lib/modules/$(uname -r)/kernel/net/ipv4
# depmod -a

#     echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
#     echo "net.ipv4.tcp_congestion_control=nanqinlang" >> /etc/sysctl.conf
#     sysctl -p
    
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p
mkdir tcp_nanqinlang
cd tcp_nanqinlang
wget -N https://raw.githubusercontent.com/IloveJFla/oneto/master/BBRnanqinlang/tcp_nanqinlang.c
wget -N https://raw.githubusercontent.com/IloveJFla/oneto/master/BBRnanqinlang/Makefile
make && make install
clear
sysctl net.ipv4.tcp_available_congestion_control
lsmod | grep bbr
echo -e "${Info}魔改版BBR启动成功！"
}


#卸载全部加速
remove_all(){
    rm -rf bbrmod
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    sed -i '/fs.file-max/d' /etc/sysctl.conf
    sed -i '/net.core.rmem_max/d' /etc/sysctl.conf
    sed -i '/net.core.wmem_max/d' /etc/sysctl.conf
    sed -i '/net.core.rmem_default/d' /etc/sysctl.conf
    sed -i '/net.core.wmem_default/d' /etc/sysctl.conf
    sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
    sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_tw_recycle/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.conf
    sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_mtu_probing/d' /etc/sysctl.conf
    sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
    sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
    sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
    sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
    sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
    sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
    clear
    echo -e "${Info}:清除加速完成。"
    sleep 1s
}

#############内核管理组件#############

#删除多余内核
detele_kernel(){
  if [[ "${release}" == "centos" ]]; then
    rpm_total=`rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | wc -l`
    if [ "${rpm_total}" > "1" ]; then
      echo -e "检测到 ${rpm_total} 个其余内核，开始卸载..."
      for((integer = 1; integer <= ${rpm_total}; integer++)); do
        rpm_del=`rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | head -${integer}`
        echo -e "开始卸载 ${rpm_del} 内核..."
        yum remove -y ${rpm_del}
        echo -e "卸载 ${rpm_del} 内核卸载完成，继续..."
      done
      echo -e "内核卸载完毕，继续..."
    else
      echo -e " 检测到 内核 数量不正确，请检查 !" && exit 1
    fi
  elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
    deb_total=`dpkg -l | grep linux-image | awk '{print $2}' | grep -v "${kernel_version}" | wc -l`
    if [ "${deb_total}" > "1" ]; then
      echo -e "检测到 ${deb_total} 个其余内核，开始卸载..."
      for((integer = 1; integer <= ${deb_total}; integer++)); do
        deb_del=`dpkg -l|grep linux-image | awk '{print $2}' | grep -v "${kernel_version}" | head -${integer}`
        echo -e "开始卸载 ${deb_del} 内核..."
        apt-get purge -y ${deb_del}
        echo -e "卸载 ${deb_del} 内核卸载完成，继续..."
      done
      echo -e "内核卸载完毕，继续..."
    else
      echo -e " 检测到 内核 数量不正确，请检查 !" && exit 1
    fi
  fi
}

#更新引导
BBR_grub(){
  if [[ "${release}" == "centos" ]]; then
        if [[ ${version} = "6" ]]; then
            if [ ! -f "/boot/grub/grub.conf" ]; then
                echo -e "${Error} /boot/grub/grub.conf 找不到，请检查."
                exit 1
            fi
            sed -i 's/^default=.*/default=0/g' /boot/grub/grub.conf
        elif [[ ${version} = "7" ]]; then
            if [ ! -f "/boot/grub2/grub.cfg" ]; then
                echo -e "${Error} /boot/grub2/grub.cfg 找不到，请检查."
                exit 1
            fi
            grub2-set-default 0
        fi
    elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
        /usr/sbin/update-grub
    fi
}

#############内核管理组件#############

cgtime(){
sudo apt-get install ntpdate -y
ntpdate time.windows.com
# cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
rm -rf /etc/localtime 
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

cglang(){
wget -O lang.sh https://raw.githubusercontent.com/IloveJFla/oneto/master/lang.sh && bash lang.sh
}

cgspeed(){
wget -O superspeed.sh https://raw.githubusercontent.com/IloveJFla/oneto/master/superspeed.sh && bash superspeed.sh
}

cgbensh(){
wget -O bench.sh https://raw.githubusercontent.com/IloveJFla/oneto/master/bench.sh && bash bench.sh
}

#优化系统配置
optimizing_system(){
    sed -i '/fs.file-max/d' /etc/sysctl.conf
    sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
    sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
    sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
    sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
    sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
    sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
    echo "fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
# forward ipv4
net.ipv4.ip_forward = 1">>/etc/sysctl.conf
    sysctl -p
    echo "*               soft    nofile           1000000
*               hard    nofile          1000000">/etc/security/limits.conf
    echo "ulimit -SHn 1000000">>/etc/profile
    read -p "需要重启VPS后，才能生效系统优化配置，是否现在重启 ? [Y/n] :" yn
    [ -z "${yn}" ] && yn="y"
    if [[ $yn == [Yy] ]]; then
        echo -e "${Info} VPS 重启中..."
        reboot
    fi
}

cleanlj(){
detele_kernel
sudo apt-get autoclean -y
sudo apt-get clean -y
sudo apt-get autoremove -y
sudo dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge
}


start_menu(){
clear
echo -e "${Info} 选择你要使用的功能: "
echo -e "0.设置中文和时区\n1.初始化\n2.安装BBR\n3.开启BBR\n4.安装魔改BBR\n5.开启魔改BBR\n6.国内测速\n7.VPS参数\n8.优化网络\n9.清理垃圾"
echo
read -p " 请输入数字 [0-9]:" num
case "$num" in
    0)
    cglang
    cgtime
    ;;
    1)
    initialization
    ;;
    2)
    BBRinstall
    ;;
    3)
    BBRstart
    ;;
    4)
    MBBRinstall
    ;;
    5)
    MBBRstart
    ;;
    6)
    cgspeed
    ;;
    7)
    cgbensh
    ;;
    8)
    optimizing_system
    ;;
    9)
cleanlj
    ;;
    *)
    clear
    echo -e "${Error}:请输入正确数字 [0-9]"
    sleep 5s
    start_menu
    ;;
esac
}


start_menu
