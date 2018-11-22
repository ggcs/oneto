sudo apt-get install software-properties-common
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install g++-4.9
sudo apt-get install libelf-dev
ln -sf which gcc-4.9 /usr/bin/gcc ---only if you upgraded gcc manually------
wget -qO 'BBR_POWERED.sh' 'https://github.com/IloveJFla/oneto/master/bbr/BBR_POWERED.sh' && chmod a+x BBR_POWERED.sh && bash BBR_POWERED.sh -f v4.14.12
