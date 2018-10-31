sed -i "s/#Port .*/Port 23456/g" /etc/ssh/sshd_config && systemctl restart sshd.service
firewall-cmd --permanent --zone=public --add-port=23456/tcp
firewall-cmd --reload
firewall-cmd --permanent --query-port=23456/tcp
yum provides semanage
yum -y install policycoreutils-python
semanage port -a -t ssh_port_t -p tcp 23456
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

cd
wget http://cachefly.cachefly.net/100mb.test


yum update
#CentOS 7系统
#导入ELRepo公钥
wget https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm --import RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install kernel-ml -y
grub2-mkconfig -o /boot/grub2/grub.cfg && grub2-set-default 0
reboot

uname -r
cat >>/etc/sysctl.conf << EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
sysctl -p
lsmod | grep bbr

yum clean all
