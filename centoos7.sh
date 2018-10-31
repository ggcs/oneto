#!/bin/bash
#################################################
#   CentOS7初始化脚本
#   
#   wget -O centoos7.sh https://raw.githubusercontent.com/IloveJFla/oneto/master/centoos7.sh && bash centoos7.sh
#   wget https://github.com/IloveJFla/oneto/blob/master/centoos7.sh && bash centoos7.sh
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


yum install screen zip unzip curl curl-devel wget -y
yum -y install gcc gcc-c++ kernel-devel
yum install -y ncurses-devel
mkdir htop
cd htop
wget https://hisham.hm/htop/releases/2.2.0/htop-2.2.0.tar.gz
tar zxvf htop-2.2.0.tar.gz
cd htop-2.2.0
./configure
make
make install
cd

yum -y install gcc gcc-c++ make wget
yum -y install python-urwid
wget http://excess.org/speedometer/speedometer-2.8.tar.gz
tar -zxvvf speedometer-2.8.tar.gz
cd speedometer-2.8
python setup.py install
cd

yum -y install wget unzip gcc gcc-c++ openssl-devel
wget https://github.com/aria2/aria2/releases/download/release-1.34.0/aria2-1.34.0.tar.gz
tar xzvf aria2-1.34.0.tar.gz
cd aria2-1.34.0
./configure
make
make install
cd
aria2c -v

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


yum update
#CentOS 7系统
#导入ELRepo公钥
wget https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm --import RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install kernel-ml -y
grub2-mkconfig -o /boot/grub2/grub.cfg && grub2-set-default 0
echo -e "${Info} 确认内核安装无误后, ${reboot}你的VPS, 开机后再次运行该脚本的第二项！重新连接的端口号为$rnd"

    read -e -p "是否现在重启 ? [Y/n] :" yn
    [[ -z "${yn}" ]] && yn="y"
    if [[ $yn == [Yy] ]]; then
        echo -e "${Info} VPS 重启中..."
        reboot
    fi

}


start(){
check_system
check_root
check_kvm
yum clean all
uname -r
cat >>/etc/sysctl.conf << EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
sysctl -p
lsmod | grep bbr

# cd
# wget http://cachefly.cachefly.net/100mb.test

}

cgtime(){
\cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo 'Asia/Shanghai' >/etc/timezone
}

cglang(){
yum -y install kde-l10n-Chinese
localectl  set-locale LANG=zh_CN.UTF8
}

cgspeed(){
wget -O superspeed.sh https://raw.githubusercontent.com/IloveJFla/oneto/master/superspeed.sh && bash superspeed.sh
}

cgbensh(){
wget -O bench.sh https://raw.githubusercontent.com/IloveJFla/oneto/master/bench.sh && bash bench.sh
}

echo -e "${Info} 选择你要使用的功能: "
echo -e "1.初始化\n2.开启BBR算法\n3.设置中文\n4.设置时区\n5.测速\n6.VPS参数"
read -p "输入数字以选择:" function

while [[ ! "${function}" =~ ^[1-6]$ ]]
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
elif [[ "${function}" == "4" ]]; then
    cgtime
elif [[ "${function}" == "5" ]]; then
    cgspeed
else
    cgbensh
fi
