#!/bin/sh


#  For future consideration about library removam um production environment

#  #  Strong Candidates from Removal:
#  libasan			GCC AddressSanitizer runtime
#  liblsan			GCC LeakSanitizer runtime
#  libtsan			GCC ThreadSanitizer runtime
#  libubsan			GCC UndefinedBehaviorSanitizer runtime
#  libcilkrts			GCC Cilk Plus parallel programming runtime
#  libvtv			C++ virtual table verification
#  libitm			GCC transactional memory
#  libgomp-plugin-host_nonshm	OpenMP offloading plugin
#  libSegFault			glibc stack-trace/debugging helper
#  libmemusage			glibc memory-usage profiling
#  libpcprofile			glibc program-counter profiling
#  libBrokenLocale		Compatibility with legacy locale behavior
#  sotruss-lib			Support library for glibc's sotruss tracing utility
#  libncurses++w		C++ wrappers for ncurses
#  libgnutlsxx			C++ wrapper for GnuTLS
#  libgmpxx			C++ wrapper for GMP
#  libpcre2-posix		POSIX regex compatibility interface for PCRE2
#  
#  # More Strong Candidates for Removal
#  libmvec			glibc vectorized mathematical functions	(Not required for ordinary scalar libm operations)
#  libquadmath			128-bit floating-point mathematics	(Usually unnecessary outside specialized numerical software
#  libmpc			Complex-number mathematics used by GCC	(Required for some GCC components at build/runtime)
#  libssp			GCC stack-smashing protection runtime	(Do not confuse with glibc's built-in stack protector support)
#  
#  # More Removal Candidates (but very dependent on what is installed)
#  libatomic			GCC atomic operations					(Keep if any programs require its runtime symbols)
#  libgdbm, libgdbm_compat	GNU database manager					(Needed only for applications using GDBM database)
#  libform, libmenu, libpanel	Optional ncurses user-interface libraries		(Not required by basic terminal operations)
#  libcaca++			C++ interface for libcaca				(Not needed for the C interface)
#  libssh2			SSH client protocol library	Independent of OpenSSH  (only required by applications using libssh2)
#  libltdl			Libtool dynamic-module loader				(May be used for loading plugins)
#  libparted-fs-resize		Filesystem resize support for libparted			(Check whether your parted build uses it)
#  
#  # More Removal Candidates
#  libevent, libevent_extra,	Event loop and asynchronous I/O	Remove only if no applications use them
#  libevent_openssl,
#  libevent_pthreads
#
#  # Script to find libs in use by executables
#
#  find / -type f -exec file -L {} + 2>/dev/null | 
#    grep -E 'ELF.*(executable|shared object)' |
#    cut -d: -f1 |
#    while IFS= read -r file; do ldd "$file" 2>/dev/null; done |
#    awk '/=> \// {print $3} /^[[:space:]]*\// {print $1}' |
#    while read f; do basename $f; done |
#    sed -E 's/(-[0-9.]+)?\.so.*$//' |
#    sort -u > 
#		/tmp/libs.txt
#
#
#  # Script to find shared objects in system (NOT ALL ARE DYNAMIC LIBRARIES USED BY EXECUTABLE)
#
#  find /lib /usr/lib /opt \( -type f -o -type l \) -name '*.so*' -exec file -L {} + 2>/dev/null |
#    grep 'ELF.*shared object' |
#    cut -d: -f1 |
#    while IFS= read -r f; do basename "$f"; done |
#    sed -E 's/(-[0-9.]+)?\.so.*$//' |
#    sort -u >
#		/tmp/libs_in_system.txt
#
#



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

# clean /usr/share/info
rm -rf $LFS/usr/share/doc
rm -rf $LFS/usr/share/info
rm -rf $LFS/usr/share/gtk-doc

# Removing localization database (not supporting translated messages)
# This is software translated messages for supported languages
rm -rf $LFS/usr/share/locale/*

# No doc/spell for vim, neither tutorial
rm -rf $LFS/usr/share/vim/vim72/doc
rm -rf $LFS/usr/share/vim/vim72/tutor
rm -rf $LFS/usr/share/vim/vim72/spell

#
# clean /usr/share/man
# This will remove translated manuais that goes in /usr/share/man/<lang>/manX
# This will remove translated manuais that goes in /usr/share/man/<lang>/catX
# Keeping only /usr/share/man/manX and /usr/share/man/catX
#
if [ -d $LFS/usr/share/man ]
then
(
	cd $LFS/usr/share/man
	du -sk * | grep -v cat | grep -v man | cut -f 2 | while read d; do rm -rf $d; done
)
fi

# Remove more stuff in pro environment
if [ "$dev" = no ]
then
	echo; echo 'AbdLFS: Removing gcc, docs, info, man, static libs (.a) and more from pro'; echo

	# Removing gcc keeping libraries !
	sort $LFS/installlogs/cksum.gcc.after.txt > /tmp/gcc.after.sort.txt
	sort $LFS/installlogs/cksum.gcc.before.txt > /tmp/gcc.before.sort.txt

	diff /tmp/gcc.before.sort.txt /tmp/gcc.after.sort.txt |
	egrep -e '^>'| awk '{ print $4 }' |
	while read file
        do
		b=`dirname $file`
		if [ "$b" != "/usr/lib" ]
		then
			rm -f $LFS/$file
		fi
	done

	rm  -f /tmp/gcc.after.sort.txt
	rm  -f /tmp/gcc.before.sort.txt
	
	# Removes the link cc -> gcc
	rm  -f $LFS/usr/bin/cc
	rm -rf $LFS/usr/lib/gcc
	rm -rf $LFS/usr/libexec/gcc
	rm -rf $LFS/usr/share/gcc-*

	# Removing includes
	rm -rf $LFS/usr/include

	# Removing static libs
	rm  -f $LFS/lib/*.a $LFS/usr/lib/*.a $LFS/usr/local/lib/*.a

	# No more compilations in pro  env
	rm -rf $LFS/usr/lib/pkgconfig
	rm -rf $LFS/lib/pkgconfig

	rm -rf $LFS/usr/lib/cmake

	# Removing unneeded in /usr/share
	# Most os those dir contains:
	# Documentations, development related material, and nor used GUI related data
	for dir in info man doc aclocal bison gdb libtool getopt applications icons
	do
		if [ -d "$LFS/usr/share/$dir" ]; then
			rm -rf "$LFS/usr/share/$dir"
		else
			echo "Warning: $LFSSCRIPTNAME: Trying to remove unexistent $LFS/usr/share/$dir"
		fi
	done

	# Remove unneeded in /usr/bin
	# Most of those binaries are development related
	for bin in \
		addr2line ar as bison c++filt caca-config cc curl-config event_rpcgen.py          \
		flex gdbus-codegen gencat glib-genmarshal glib-gettextize glib-mkenums gtester    \
		gtester-report ld ld.bfd lex libtool libtoolize make ncursesw6-config nm          \
		objcopy onig-config pcap-config pcre2-config pcre2test pkg-config pod2mdoc rpcgen \
		strip xml2-config yacc
	do
		if [ -f "$LFS/usr/bin/$bin" ]; then
			rm -rf "$LFS/usr/bin/$bin"
		else
			echo "Warning: $LFSSCRIPTNAME: Trying to remove unexistent $LFS/usr/bin/$bin"
		fi
	done
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

# Clearing /tmp
rm -rf $LFS/tmp/* $LFS/var/tmp/*

# Remove /installlogs
echo; echo 'Remove /installlogs';echo
rm -rf $LFS/installlogs

# Removing toolchain
echo; echo 'AbdLFS: Removing /tools';echo
rm -rf $LFS/tools

echo; echo "AbdLFS: $(date +%Y%m%d-%H%M%S) - Finished $LFSSCRIPTNAME"; echo

