# 一键VPS初始化脚本

------

## CentOS7初始化脚本

```
wget -O CentOS7.sh https://raw.githubusercontent.com/IloveJFla/oneto/master/CentOS7.sh && chmod a+x CentOS7.sh && bash CentOS7.sh
```
## Ubuntu16初始化脚本

```
wget -O Ubuntu16.sh https://raw.githubusercontent.com/IloveJFla/oneto/master/Ubuntu16.sh && chmod a+x Ubuntu16.sh && bash Ubuntu16.sh
```

## 提示错误
```
# CentOS系统:
yum install -y wget

# Debian/Ubuntu系统:
apt-get install -y wget
```
## 提示wget: unknown host “raw.githubusercontent.com” 之类的错误
```
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf
```
