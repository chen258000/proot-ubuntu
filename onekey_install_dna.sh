#!/data/data/com.termux/files/usr/bin/bash

cd $HOME


termux-change-repo

clear


case `dpkg --print-architecture` in
	aarch64|armv*)
		arch="arm64"
		if [ ! -d ~/storage  ]; then
			termux-setup-storage
		fi
		;;
	*)
		echo "系统架构【$(dpkg --print-architecture)】不支持"
		exit 1
		;;
esac

if [[ -x "$(command -v pkg)" ]]; then
	pkg update -y
	APT="pkg"
else
	APT="apt"
fi
if [[ ! -x $(command -v proot) ]] || [[ ! -x $(command -v wget) ]] || [[ ! -x $(command -v tar) ]]; then
	$APT install tar proot wget -y
fi

linux="ubuntu"
linux_ver="focal"



if [ -d $HOME/$linux ]; then
	echo "安装中断，由于$HOME/${linux}文件夹已存在，请执行[ rm -rf $HOME/$linux ]清理后重新安装！"
	exit 1
fi

if [ -f $HOME/proot-ubuntu/${linux}.tar.xz ] && [ -f $HOME/proot-ubuntu/install_ubuntu.sh ]; then
	mv -f $HOME/proot-ubuntu/ubuntu.tar.xz $HOME
	rm -rf $HOME/proot-ubuntu
fi

if [ ! -f $HOME/${linux}.tar.xz ]; then
	if [ ! -f $HOME/images.json ]; then
		wget "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/streams/v1/images.json"
	fi
	#解析json
	rootfs_url=`cat images.json | awk -F '[,"}]' '{for(i=1;i<=NF;i++){print $i}}' | grep "images/${linux}/" | grep "${linux_ver}" | grep "/${arch}/default/" | grep "rootfs.tar.xz" | awk 'END {print}'`
	clear
	echo "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/${rootfs_url}"
	rm images.json >/dev/null
	if [ $rootfs_url ]; then
		echo "正在下载 ${linux} ${linux_ver} ..."
		wget -c --user-agent="Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.204 Safari/534.16" -O $HOME/${linux}.tar.xz "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/${rootfs_url}" && echo "下载完成 !"

	else
		echo "错误: 未找到 ${linux} ${linux_ver} !"
		exit 1
	fi
fi

if [ -f $HOME/${linux}.tar.xz ]; then
	clear
	echo "开始安装 ..."

	mkdir -p "$HOME/$linux"
	cd "$HOME/$linux"
	echo "正在解压rootfs，请稍候 ..."
	proot --link2symlink tar -xJf $HOME/${linux}.tar.xz --exclude='dev' --exclude='etc/rc.d' --exclude='usr/lib64/pm-utils'
	echo "更新DNS ..."
	echo "127.0.0.1 localhost" > etc/hosts
	rm -rf etc/resolv.conf
	echo "nameserver 114.114.114.114" > etc/resolv.conf
	echo "nameserver 8.8.4.4" >> etc/resolv.conf
	echo "export  TZ='Asia/Shanghai'" >> root/.bashrc
	echo "更换国内源 ..."
	# 清华源
	#mv etc/apt/sources.list etc/apt/sources.list.bak
	#echo -e "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal main restricted universe multiverse\ndeb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-updates main restricted universe multiverse\ndeb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-backports main restricted universe multiverse\ndeb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-security main restricted universe multiverse" >> etc/apt/sources.list
	# 中科大
	cp -rf etc/apt/sources.list etc/apt/sources.list.bak
	sed -i 's/ports.ubuntu.com/mirrors.ustc.edu.cn/g' etc/apt/sources.list
	echo -e "if [ -d DNA ] && [ -f DNA/run.py ]; then\n\tpushd DNA >/dev/null\n\tchmod -R 777 Insides/*\n\tpython3 run.py\n\tpopd >/dev/null\nfi\n" >> root/.bashrc
	cd "$HOME"

	if [ $linux == "ubuntu" ]; then
		touch "$HOME/${linux}/root/.hushlogin"
	fi

	bin=$PREFIX/bin/${linux}

	echo "写入启动脚本 ..."
cat > $bin <<- EOM
#!/bin/bash
cd $HOME

unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $linux"

command+=" -b /dev"
command+=" -b /proc"
command+=" -b $linux/root:/dev/shm"

command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"

if [ -z "\$1" ]; then
    exec \$command
else
    \$command -c "\$com"
fi
EOM


	termux-fix-shebang $bin

	chmod +x $bin

	echo "回收垃圾 ..."
	rm $HOME/$linux.tar.xz
	if [ -d "$HOME/.git" ]; then
		rm -rf "$HOME/.git" "$HOME/.gitignore" "LICENSE" "README.md" 2>/dev/null 2>&1
	fi

cat <<Errors >$HOME/ubuntu/tmp/dna.sh
rm -f /tmp/dna.sh

echo "更新Ubuntu可用软件包列表和已安装的软件包 ..."
apt update && apt upgrade -y


echo "安装一些依赖软件包 ..."
#apt install git cpio aria2 brotli android-sdk-libsparse-utils openjdk-11-jre p7zip-full -y
apt install git cpio brotli android-sdk-libsparse-utils e2fsprogs -y

echo "下载安装 D.N.A ..."
#git clone https://gitee.com/sharpeter/DNA.git --depth 1
git clone https://gitee.com/sharpeter/DNA2 -b feature --depth 1

echo "启动 D.N.A ..."
cd DNA2 && python3 start.py
Errors


	echo "启动 Ubuntu 20.04 [Focal] ..."
	ubuntu bash /tmp/dna.sh
fi
