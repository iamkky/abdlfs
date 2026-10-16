#!/bin/bash

# Check if an argument was provided
if [ $# -ne 1 ]; then
    echo "Error: Missing argument. Usage: $0 <root dir>"
    echo "<root dir> is usually tmplfs/dev or tmplfs/pro"
    exit 1
fi

# Check if the argument is a directory
if [ ! -d "$1" ]; then
    echo "Error: '$1' is not a directory."
    exit 1
fi

export LFS=$1

if [ -f "$LFS"/bin/env ]
then
	echo "Found $LFS/bin/env... using it"
	chroot "$LFS" /bin/env -i  HOME=/root TERM="$TERM" PS1='\u:\w chroot \$ ' PATH=/bin:/sbin:/usr/bin:/usr/sbin /bin/bash --login +h
elif [ -f "$LFS"/usr/bin/env ]
then
	echo "Found $LFS/usr/bin/env... using it"
	chroot "$LFS" /usr/bin/env -i  HOME=/root TERM="$TERM" PS1='\u:\w chroot \$ ' PATH=/bin:/sbin:/usr/bin:/usr/sbin /bin/bash --login +h
else
	echo "Could not find neither /bin/env /usr/bin/env"
fi

echo "Leaving LFS at $LFS"


