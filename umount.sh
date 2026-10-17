#!/bin/sh

if [ $# -ne 1 ]; then
    echo "Error: Missing argument. Usage: $0 <root dir>"
    echo "<root dir> is usually tmplfs/dev or tmplfs/pro"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "Error: '$1' is not a directory."
    exit 1
fi

export LFS=$1

umount -vt devpts devpts $LFS/dev/pts
umount -vt tmpfs shm $LFS/dev/shm
umount -vt proc proc $LFS/proc
umount -vt sysfs sysfs $LFS/sys

