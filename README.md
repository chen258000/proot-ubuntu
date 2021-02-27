# Proot Ubuntu Focal Arm64[20.04]

####  **软件架构** 

1. 手机Termux Arm64[aarch64]


####  **安装教程** 

1.  手机安装原版[Termux.apk](https://f-droid.org/repo/com.termux_103.apk)  打开Termux 获取存储权限
    - $ `termux-setup-storage`

2.  下载wget、git、tar、proot【复制下面命令，在Termux中输入，回车】
    - $ `pkg install wget git tar proot -y`

3.  下载ubuntu.tar.xz【复制下面命令，在Termux中输入，回车】
    - $ `git clone https://gitee.com/sharpeter/proot-ubuntu`
    下载慢也可直接跳过，删除已下载的proot-ubuntu，进行第4步

4.  解压安装【复制下面命令，在Termux中输入，回车】
    - $ `wget https://gitee.com/sharpeter/proot-ubuntu/raw/master/install_ubuntu.sh`
    - $ `bash install_ubuntu.sh`

5.  启动ubuntu 20.04【复制下面命令，在Termux中输入，回车】
    - $ `ubuntu`
	- 【 **注意** 】 注意看  ~ 变成 root@localhost  就说明 ubuntu 已经启动了 ，如果报错了就 【 `rm -rf ubnutu` 】 再从第3步开始！！！