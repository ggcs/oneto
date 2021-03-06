#!/bin/bash
#################################################
#   CentOS7初始化脚本
#   
#   yum -y install screen zip unzip curl curl-devel wget 
#   wget -O CentOS7.sh https://raw.githubusercontent.com/IloveJFla/oneto/master/CentOS7.sh && bash CentOS7.sh
#   wget -O CentOS7.sh https://github.com/IloveJFla/oneto/blob/master/CentOS7.sh && bash CentOS7.sh
#   bash -c "$(curl -sS https://raw.githubusercontent.com/IloveJFla/oneto/master/CentOS7.sh)"
#   
#################################################
#

Green_font="\033[32m" && Yellow_font="\033[33m" && Red_font="\033[31m" && Font_suffix="\033[0m"
Info="${Green_font}[Info]${Font_suffix}"
Error="${Red_font}[Error]${Font_suffix}"
reboot="${Yellow_font}重启${Font_suffix}"
echo -e "${Green_font}
#================================================
#              CentOS7初始化脚本
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
[[ ${release} != "centos" ]]  && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
}

check_root(){
    [[ "`id -u`" != "0" ]] && echo -e "${Error} must be root user !" && exit 1
}

check_kvm(){
    [[ -d "/proc/vz" ]] && echo -e "${red}Error:${plain} Your VPS is based on OpenVZ, which is not supported." && exit 1
}


rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(($RANDOM+1000000000)) #增加一个10位的数再求余
    echo $(($num%$max+$min))
}
 



install(){

check_system
check_root
check_kvm

resize2fs /dev/vda1

rnd=$(rand 40000 50000)

# echo "重新连接的端口号为$rnd"
# exit 1

sed -i "s/#Port .*/Port $rnd/g" /etc/ssh/sshd_config && systemctl restart sshd.service

# yum install firewalld systemd -y

firewall-cmd --permanent --zone=public --add-port=$rnd/tcp
firewall-cmd --reload
firewall-cmd --permanent --query-port=$rnd/tcp
yum provides semanage
yum -y install policycoreutils-python
semanage port -a -t ssh_port_t -p tcp $rnd
semanage port -l | grep ssh
firewall-cmd --permanent --zone=public --remove-port=22/tcp
firewall-cmd --reload
firewall-cmd --permanent --list-port
systemctl restart sshd

# mkdir htop
# cd htop
yum install screen zip unzip curl curl-devel wget -y
yum -y install gcc gcc-c++ kernel-devel
yum install -y ncurses-devel
wget https://hisham.hm/htop/releases/2.2.0/htop-2.2.0.tar.gz
tar zxvf htop-2.2.0.tar.gz
cd htop-2.2.0
./configure
make
make install
cd


# yum -y install gcc gcc-c++ make wget
# yum -y install python-urwid
# wget http://excess.org/speedometer/speedometer-2.8.tar.gz
# tar -zxvvf speedometer-2.8.tar.gz
# cd speedometer-2.8
# python setup.py install
# cd

yum -y install epel-release
yum -y install iftop
yum -y install nethogs


yum -y install wget unzip gcc gcc-c++ openssl-devel
wget https://github.com/aria2/aria2/releases/download/release-1.34.0/aria2-1.34.0.tar.gz
tar xzvf aria2-1.34.0.tar.gz
cd aria2-1.34.0
./configure
make
make install
cd


yum -y install fuse unzip
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


#bbr
 
yum update
#CentOS 7系统
#导入ELRepo公钥
wget https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm --import RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install kernel-ml -y
grub2-mkconfig -o /boot/grub2/grub.cfg && grub2-set-default 0


clear

nethogs -V
htop -v
aria2c -v
rclone -V
echo -e "${Info}htop、speedometer、aria2c、rclone成功！"
echo -e "${Info} 确认内核安装无误后, ${reboot}你的VPS, 开机后再次运行该脚本的第二项！重新连接的端口号为$rnd"

    read -e -p "是否现在重启 ? [Y/n] :" yn
    [[ -z "${yn}" ]] && yn="y"
    if [[ $yn == [Yy] ]]; then
        echo -e "${Info} VPS 重启中..."
        reboot
    fi

}

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

start(){
check_system
check_root
check_kvm
uname -r
cat >>/etc/sysctl.conf << EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
sysctl -p

detele_kernel
yum clean all
lsmod | grep bbr

}

cgtime(){
yum -y install ntpdate
ntpdate us.pool.ntp.org
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
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

echo -e "${Info} 选择你要使用的功能: "
echo -e "1.初始化\n2.开启BBR算法\n3.设置中文和时区\n4.Swap\n5.国内测速\n6.VPS参数\n7.优化网络\n8.清理垃圾"
read -p "输入数字以选择:" function

while [[ ! "${function}" =~ ^[1-8]$ ]]
    do
        echo -e "${Error} 无效输入"
        echo -e "${Info} 请重新选择" && read -p "输入数字以选择:" function
    done

if   [[ "${function}" == "1" ]]; then
    install
elif [[ "${function}" == "2" ]]; then
    start
elif [[ "${function}" == "3" ]]; then
    cglang
    cgtime
elif [[ "${function}" == "4" ]]; then
    wget -O swap.sh https://raw.githubusercontent.com/IloveJFla/oneto/master/swap.sh && bash swap.sh
elif [[ "${function}" == "5" ]]; then
    cgspeed
elif [[ "${function}" == "6" ]]; then
    cgbensh
elif [[ "${function}" == "7" ]]; then
    optimizing_system
else
    # detele_kernel
    yum remove $(rpm -qa | grep kernel | grep -v $(uname -r))
    yum clean all
    rpm -qa | grep kernel
fi
