#!/bin/bash

MIRROR=http://ftp.tu-clausthal.de/pub/DragonFly/snapshots/x86_64/
ISO=DragonFly-x86_64-LATEST-ISO.iso
FILE=${ISO}.bz2

dftree() {
        if [ ! -e df-tree ]; then 
                if [ ! -e downloads/${ISO} ]; then
                        if [ ! -e downloads/${FILE} ]; then
                                mkdir -p downloads
	                        cd downloads && wget ${MIRROR}${FILE} && cd ..
                        fi
                        cd downloads && bunzip2 ${FILE} && cd ..
                fi
                7z x -odf-tree downloads/${ISO}
        fi 
}

dftree 
