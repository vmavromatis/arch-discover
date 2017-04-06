#!/bin/bash
#A script for Arch that discovers the essential system software which is currently used.

#Define bold font
bold=$(tput bold)
normal=$(tput sgr0)

echo "Scanning system software..."

#INIT
INIT=`strings /sbin/init | awk 'match($0, /(upstart|systemd|sysvinit)/) { print substr($0, RSTART, RLENGTH);exit; }'`
INITVERSION=`pacman -Q $INIT`
echo "Init system: ${bold}$INITVERSION${normal}"

#BOOTLOADER
BL=`pacman -Q grub`
echo "Bootloader: ${bold}$BL${normal}"

#COMPOSITOR
COMP=`echo $XDG_SESSION_TYPE`
case $COMP in
	x11)
		COMP="xorg-server"
		;;
	wayland)
		COMP="wayland"
		;;
esac
COMPVERSION=`pacman -Q $COMP`
echo "Compositor: ${bold}$COMPVERSION${normal}"

#GRAPHICS
driver=`if [ -z "$1" ]; then
    logfile=/var/log/Xorg.0.log
else
    logfile="$1"
fi

sed -n 's@.* Loading .*/\(.*\)_drv.so@\1@p' "$logfile" |
    while read driver; do
        if ! grep -q "Unloading $driver" "$logfile"; then
            echo $driver | xargs echo -n	
            break
        fi
    done`


case $driver in
	radeon)
		GRAPHICS="xf86-video-ati"
		;;
esac

GRAPHICSVERSION=`pacman -Q $GRAPHICS`
echo "Graphics Driver: ${bold}$GRAPHICSVERSION${normal}"