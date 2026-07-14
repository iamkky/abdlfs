#!/bin/sh

set +h
LFSSCRIPTNAME=${BASH_SOURCE[0]}
echo; echo "AbdLFS: $(date +%Y%m%d-%H%M%S) - Starting $LFSSCRIPTNAME"; echo

startStep() {
        LFSSTEP=$1
        echo
        echo -e "##################################################################"
        echo -e "###"
        echo -e "###  AbdLFS: $(date +%Y%m%d-%H%M%S): Starting: $LFSSTEP  ($LFSSCRIPTNAME)"
        echo -e "###"
        echo
}

error_trap() {
	echo -e ""
	echo -e "+---------------------------+"
	echo -e "|   ERROR: Error trapped!   |"
	echo -e "+---------------------------+"
	exit -1
}

trap error_trap ERR

if [ D"$LFS" = "D" ]
then
	echo "You need to set "'$LFS'
	exit -1
fi

if [ D"$1" = D"dev" ]
then
	dev=yes
	startStep "strip-dev"
else
	if [ D"$1" = D"pro" ]
	then
		dev=no
		startStep "strip-pro"
	else
		echo "Usage: $0 dev|pro"
		exit
	fi
fi

# Clearing final system
echo; echo 'AbdLFS: Clearing final system';echo

# Removing toolchain sources and files
rm -rf $LFS/reqs
rm -rf $LFS/prereqs
rm -rf $LFS/devsetup
rm -rf $LFS/sources_dev
rm -rf $LFS/sources
rm -rf $LFS/extensions
rm -rf $LFS/lfs-*.sh

# clean /usr/share
rm -rf $LFS/usr/share/gtk-doc
rm -rf $LFS/usr/share/info
rm -rf $LFS/usr/share/vim/vim72/doc
rm -rf $LFS/usr/share/vim/vim72/tutor

# clean /usr/share/doc
rm -rf $LFS/usr/share/doc/groff-1.20.1
rm -rf $LFS/usr/share/doc/libxml2-2.7.8
rm -rf $LFS/usr/share/doc/bzip2-1.0.5
rm -rf $LFS/usr/share/doc/libxslt-1.1.20
rm -rf $LFS/usr/share/doc/valgrind
rm -rf $LFS/usr/share/doc/bash-4.4.18

# clean /usr/share/man
if [ -d $LFS/usr/share/man ]
then
(
	cd $LFS/usr/share/man
	du -sk * | grep -v cat | grep -v man | cut -f 2 | while read d; do rm -rf $d; done
)
fi

# Removing locale
rm -rf $LFS/usr/share/locale/*/LC_MESSAGES/*

# Clearing /tmp
rm -rf $LFS/tmp/* $LFS/var/tmp/*

# Remove more stuff only if pro environment
if [ "$dev" = no ]
then
	echo; echo 'AbdLFS: Removing gcc, docs, info, man, stati libs (.a) and more from pro';echo

	# Removing man
	rm -rf $LFS/usr/include

	# Removing gcc keeping libraries !
	sort $LFS/installlogs/cksum.gcc.after.txt > /tmp/after.sort.txt
	sort $LFS/installlogs/cksum.gcc.before.txt > /tmp/before.sort.txt
	diff /tmp/before.sort.txt /tmp/after.sort.txt |
	egrep -e '^>'| awk '{ print $4 }' |
	while read file
        do
		b=`dirname $file`
		if [ "$b" != "/usr/lib" ]
		then
			rm -f $LFS/$file
		fi
	done
	rm -f /tmp/after.sort.txt
	rm -f /tmp/before.sort.txt

	# Removing static libs
	rm -f $LFS/lib/*.a $LFS/usr/lib/*.a $LFS/usr/local/lib/*.a

	# Removing docs and vim stuff
	rm -rf $LFS/usr/share/info/*
	rm -rf $LFS/usr/share/doc/*
	rm -rf $LFS/usr/share/man/*

	# Removing vim stuff
	rm -rf $LFS/usr/share/vim/vim72/spell
fi


# If dev find binaries and libraries to strip in /opt
if [ "$dev" = yes ]
then
	echo; echo 'If dev find binaries and libraries to strip in /opt';echo
	STRIP_BINDIR=`for a in $LFS/opt/*; do  if [ -e "$a"/bin ]; then b=\`basename $a\`; echo -n /opt/$b/bin " "; fi; done`
	STRIP_LIBDIR=`for a in $LFS/opt/*; do  if [ -e "$a"/lib ]; then b=\`basename $a\`; echo -n /opt/$b/lib " "; fi; done`
fi

# Stripping libraries
echo; echo 'AbdLFS: Stripping libraries';echo
chroot "$LFS" /tools/bin/env -i HOME=/root TERM="$TERM" PS1='\u:\w\$ ' PATH=/tools/bin \
	/tools/bin/find /usr/lib /lib $STRIP_LIBDIR -type f -exec /tools/bin/strip --strip-unneeded '{}' ';'

# Stripping binaries
echo; echo 'AbdLFS: Stripping binaries';echo
chroot "$LFS" /tools/bin/env -i HOME=/root TERM="$TERM" PS1='\u:\w\$ ' PATH=/tools/bin \
	/tools/bin/find /{,usr/}{bin,sbin} $STRIP_BINDIR -type f -exec /tools/bin/strip --strip-all '{}' ';'

# Remove /installlogs
echo; echo 'Remove /installlogs';echo
rm -rf $LFS/installlogs

# Removing toolchain
echo; echo 'AbdLFS: Removing /tools';echo
rm -rf $LFS/tools

echo; echo "AbdLFS: $(date +%Y%m%d-%H%M%S) - Finished $LFSSCRIPTNAME"; echo

