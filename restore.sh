#!/bin/sh

BKDIR="`basename ./backup-*`"

function yes_no {
	MSG=$1
	while :
	do
		echo -n "${MSG}
        [y/N]: "
		read ans
		case $ans in
		[yY]) return 0 ;;
		[nN]) return 1 ;;
		esac
	done
}

function restore1 {
	yes_no "
Do you want to restore repository?"
	if [ $? -eq 0 ]; then
		\cp -rpvf `pwd`/backup-*/private/etc/apt/sources.list.d/* /etc/apt/sources.list.d/
		\cp -rpvf `pwd`/backup-*/private/var/lib/cydia/* /var/lib/cydia/
		echo "
Complete!
		"
		yes_no "
Do you want to reflesh repository?"
		if [ $? -eq 0 ]; then
			apt-get update
			echo "
Complete!
			"
		fi
	fi
	
	yes_no "
Do you want to restore tweaks?"
	if [ $? -eq 0 ]; then
		cd backup-*
		dpkg --set-selections < cydiaapp.lst
		cd ../
		apt-get -u dselect-upgrade --fix-missing -f
		echo "
Complete!
		"
	fi
	
	yes_no "
Do you want to restore files?"
	if [ $? -eq 0 ]; then
		rm -rf `pwd`/backup-*/cydiaapp.lst
		\cp -rpvf `pwd`/backup-*/* /
		rm /private/var/mobile/Library/Caches/com.apple.mobile.installation.plist
		rm -rf `pwd`/backup-*
		echo "
Complete!
		"
	fi
	
	echo "

++++ Restore Complete ++++
"
}

if [ -e `pwd`/iosbkup_*.tar.gz ]; then
	yes_no "Do you want to extract compressed file?"
	if [ $? -eq 0 ]; then
		rm -rf `pwd`/backup-*
		tar xfpvz `pwd`/iosbkup_*.tar.gz
		BKDIR="`basename ./backup-*`"
		restore1
	elif ! [ -e `pwd`/backup-* ]; then
		echo "Could not extract file!"
	else
		BKDIR="`basename ./backup-*`"
		restore1
	fi
elif ! [ -e `pwd`/backup-* ]; then
	echo "You may not put compressed file in this directory!"
else
	BKDIR="`basename ./backup-*`"
	restore1
fi
