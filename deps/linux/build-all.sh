#!/bin/bash

DISTRO="unknown"

message() {
	case "${1}" in
		info)
			echo -e "\033[1;34mINFO:\033[1;37m ${2} \033[0m"
			;;
		status)
			echo -e "\033[1;32mSTATUS:\033[1;37m ${2} \033[0m"
			;;
		warning)
			echo -e "\033[1;33mWARNING:\033[1;37m ${2} \033[0m"
			;;
		error)
			echo -e "\033[1;31mERROR:\033[1;37m ${2} \033[0m"
			;;
	esac
}

get_distro() {
	if [[ $(grep -ir "arch" /etc/issue) ]]; then
		DISTRO="archlinux"
	elif [[ -e /etc/SuSE-release ]]; then
		DISTRO="suse"
	elif [[ -e /etc/fedora-release ]]; then
		DISTRO="fedora"
	elif [[ -e /etc/debian-version ]]; then
		DISTRO="debian"
	elif [[ $(grep -ir "ubuntu" /etc/lsb-release) ]]; then
		DISTRO="ubuntu"
	else 
		message "error" "Your distribution could not be detected."
		message "error" "Please report this to the developers."
		return 1
	fi
	message "info" "Your distribution has been detected as ${DISTRO}."
}

install_deps() {
	case "${1}" in
		archlinux)
			if [[ ! -f $(which yaourt) ]]; then
				message "error" "You will need to have yaourt installed."
				message "error" "Please have a look here: http://archlinux.fr/yaourt-en"
				return 1
			fi
			sudo yaourt -Sy --noconfirm base-devel subversion git cmake ogre-svn bullet-svn codeblocks-svn
			;;
		suse)
			message "error" "SuSE distributions are currently not supported because I have no clue at all about them."
			message "error" "If you want to be awesome, submit a patch to fix this :)."
			return 1
			;;
		fedora)
			message "info" "You will manually need to install the NVIDIA Cg toolkit for your architecture."
			message "info" "Get it here: http://developer.nvidia.com/object/cg_download.html"
			read -p "Press return to continue "
			sudo yum install make automake autoconf gcc gcc-c++ pkgconfig subversion git cmake ois freeimage freetype zlib zziplib gdb codeblocks boost libXaw libXrandr checkinstall
			;;
		debian)
			message "info" "You will need to enable all repositories before attempting the installation."
			read -p "Press return to continue "
			sudo apt-get install build-essential automake pkg-config subversion git cmake libois-dev gdb codeblocks-contrib nvidia-cg-toolkit libfreeimage-dev libboost-dev libfreetype6-dev libxaw7-dev libxrandr-dev libzzip-dev zlib1g-dev checkinstall
			;;
		ubuntu)
			message "info" "You will need to enable all repositories before attempting the installation."
			read -p "Press return to continue "
			sudo apt-get install build-essential automake pkg-config subversion git cmake libois-dev gdb codeblocks-contrib nvidia-cg-toolkit libfreeimage-dev libboost-dev libfreetype6-dev libxaw7-dev libxrandr-dev libzzip-dev zlib1g-dev checkinstall
			;;
	esac
}

make_ogre() {
	svn co https://svn.ogre3d.org/svnroot/ogre/trunk ogre
	cd ogre
	mkdir build
	cd build
	cmake .. || return 1
	make -j3 || return 1
	sudo checkinstall
	if [[ ${DISTRO} == "debian" || ${DISTRO} == "ubuntu" ]]; then
		sudo dpkg -r *.deb
	elif [[ ${DISTRO} == "suse" || ${DISTRO} == "fedora" ]]; then
		sudo rpm - i *.rpm
	fi
}

make_bullet() {
	echo "TODO"
}

message "warning" "This script is really hacky and probably won't work for all systems."
message "warning" "Please help us improve it! Send error reports and patches if there are any problems."
sleep 3
get_distro || exit 1 
install_deps ${DISTRO} || exit 1

if [[ ${DISTRO} == "archlinux" ]]; then
	# If archlinux got this far, everything is already built
	message "info" "Everything is done :)."
	exit 0
fi

message "status" "Everything looks good, starting build process."

make_ogre || exit 1
make_bullet || exit 1

# vim: ts=2 sw=2