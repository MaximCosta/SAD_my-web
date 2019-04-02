#!/bin/bash
echo "[i] Welcome to chroot."
echo "> Linking /hostlvm to /run/lvm..."
ln -s /hostlvm /run/lvm
echo "> Setting the persistant timezone to Europe/Paris..."
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
echo "> Syncing clock with hardware clock..."
hwclock --systohc --utc
echo "> Setting locale to English (US) (UTF-8)..."
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "> Setting the persistant keymap to French AZERTY..."
echo "KEYMAP=fr-latin1" > /etc/vconsole.conf
echo "> Setting hostname to labasr.lan..."
echo "labasr.lan" > /etc/hostname
echo "> Installing wget (to download config files from GitHub Gist)..."
pacman --noconfirm -S wget
echo "> Editing /etc/hosts..."
wget -qO/etc/hosts https://gist.github.com/fanfan54/35418fe39aa5485706d86e8db094da5f/raw/7538cbffd1af2465ea250b94d1c98b5081b7f610/hosts
chmod 644 /etc/hosts
echo "> Recreating init cpio..."
mkinitcpio -p linux
echo "> Setting root password to 'password'..."
usermod --password $(openssl passwd -1 password) root
echo "> Installing the GRUB 2 bootloader (in UEFI mode)..."
pacman --noconfirm -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
echo "> Editing the default settings for GRUB (workaround to detect LVM partitions)..."
wget -qO/etc/default/grub https://gist.github.com/fanfan54/ffbc4d64af24fe8a1f52c95fa506c8e7/raw/fe852b2b2245cea74b189e905c3a58ab9df0e015/grub
chmod 644 /etc/default/grub
echo "> Generating config file for Grub"
grub-mkconfig -o /boot/grub/grub.cfg

echo "Done. Going back to arch iso..."
echo "[i] It is now safe to reboot your computer, using the 'reboot' command"
exit
