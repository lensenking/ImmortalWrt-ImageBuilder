#!/bin/sh
if [ -f /mnt/banner ]; then
    cp /mnt/banner /etc/banner
    rm /mnt/banner
fi
