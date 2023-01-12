#! /bin/bash

# get and strip pNUMBER from device
dev=$(df /|tail -n1|awk '{print $1}' | sed 's/p[0-9]*$//') 
#if dev starts with /dev/mapper/ then we need to get the real device
# lsblk -sJp | jq -r --arg dsk '{$DEV}' '.blockdevices | .[] | select(.name == $dsk) | .children | .[0] | .name'
if [[ $dev == /dev/mapper/* ]]; then
    dev=$(lsblk -sJp | jq -r --arg dsk "${dev}" '.blockdevices | .[] | select(.name == $dsk) | .children | .[0] | .name')
fi
# install 
rm /etc/sudoers.d/g_wheel
dd if=/boot/Tow-Boot.noenv.bin of=$dev seek=64 conv=notrunc,fsync
# replace MODULES= line in etc/mkinitcpio.conf with MODULES=(rtc_rk808 rockchipdrm panel_edp pwm_bl crc32c)
sed -i 's/^MODULES=.*/MODULES=(rtc_rk808 rockchipdrm panel_edp pwm_bl crc32c)/' /etc/mkinitcpio.conf
mkinitcpio -P
chmod +x /usr/bin/update-extlinux
update-extlinux