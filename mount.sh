#!/bin/bash

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

mount -vt devpts devpts $LFS/dev/pts
mount -vt tmpfs shm $LFS/dev/shm
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
