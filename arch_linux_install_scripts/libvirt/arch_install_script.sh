#!/bin/bash
echo "[B-SAD-200_my-web part 1] auto installer for Arch Linux in my-client"
echo "Authors: francois.lefevre@epitech.eu laurent.gelard@epitech.eu"
echo "-----"

echo "> Loading french (AZERTY) keys..."
loadkeys fr-latin1
echo "> Enabling auto time update via NTP..."
timedatectl set-ntp true
echo "> Setting timezone to Europe/Paris..."
timedatectl set-timezone Europe/Paris
echo "> Creating a GPT partition table..."
parted -s /dev/vda mktable gpt
echo "> Creating the EFI ESP partition (550MB)..."
parted -s /dev/vda mkpart primary fat32 0 550MB
echo "> Setting the esp flag on the partition..."
parted -s /dev/vda set 1 esp on
echo "> Creating the LVM partition for Arch Linux (16GB)..."
parted -s /dev/vda mkpart primary ext2 550MB 16550MB
echo "> Setting the lvm flag on the partition..."
parted -s /dev/vda set 2 lvm on
echo "> Creating the root partition for Debian (10GB)..."
parted -s /dev/vda mkpart primary ext4 16550MB 26550MB
echo "> Creating the home partition for Debian (4.5GB)..."
parted -s /dev/vda mkpart primary ext4 26550MB 31050MB
echo "> Creating the boot partition for Debian (500MB)..."
parted -s /dev/vda mkpart primary ext2 31050MB 31550MB
echo "> Creating the swap partition for Debian (500MB)..."
parted -s /dev/vda mkpart primary linux-swap 31550MB 32050MB
echo "> Creating the volume group archvg..."
vgcreate archvg /dev/vda2
echo "> Creating the logical volume for ROOT (9GB)..."
lvcreate -L 9G archvg -n ROOT
echo "> Creating the logical volume for HOME (5GB)..."
lvcreate -L 5G archvg -n HOME
echo "> Creating the logical volume for BOOT (400MB)..."
lvcreate -L 400M archvg -n BOOT
echo "> Creating the logical volume for SWAP (500MB)..."
lvcreate -L 500M archvg -n SWAP
echo "> Formatting the EFI ESP partition to fat32..."
mkfs.fat -F32 /dev/vda1
echo "> Formatting the logical volume for ROOT to ext4..."
mkfs.ext4 /dev/archvg/ROOT
echo "> Formatting the logical volume for HOME to ext4..."
mkfs.ext4 /dev/archvg/HOME
echo "> Formatting the logical volume for BOOT to ext2..."
mkfs.ext2 /dev/archvg/BOOT
echo "> Formatting the logical volume for SWAP to linux-swap..."
mkswap /dev/archvg/SWAP
echo "> Formatting the root partition for Debian to ext4..."
mkfs.ext4 /dev/vda3
echo "> Formatting the home partition for Debian to ext4..."
mkfs.ext4 /dev/vda4
echo "> Formatting the boot partition for Debian to ext2..."
mkfs.ext2 /dev/vda5
echo "> Formatting the swap partition for Debian to linux-swap..."
mkswap /dev/vda6
echo "> Enabling swap for Arch Linux..."
swapon /dev/archvg/SWAP
echo "> Mounting /root..."
mount /dev/archvg/ROOT /mnt
echo "> Creating mount points..."
mkdir /mnt/boot
mkdir /mnt/efi
mkdir /mnt/home
echo "> Mounting /home..."
mount /dev/archvg/HOME /mnt/home
echo "> Mounting /boot..."
mount /dev/archvg/BOOT /mnt/boot
echo "> Mounting the EFI ESP partition..."
mount /dev/vda1 /mnt/efi
echo "> Settings mirror list to use archlinux.fr only..."
echo "Server = http://mir.archlinux.fr/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
echo "> Installing base packages..."
pacstrap /mnt base
echo "> Installing base-devel packages..."
pacstrap /mnt base-devel
echo "> Editing mkinitcpio.conf to be able to boot on LVM..."
wget -qO/mnt/etc/mkinitcpio.conf https://gist.github.com/fanfan54/7c642af2a366afc34663a60e004b16a9/raw/e61b736dfbeaec06c9643a99bb93fa24dc6e12f2/mkinitcpio.conf
chmod 644 /mnt/etc/mkinitcpio.conf
echo "> Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
echo "> Mounting /hostlvm (workaround for a lvm2 bug)..."
mkdir /mnt/hostlvm
mount --bind /run/lvm /mnt/hostlvm
echo "> Going in chroot into your new system. Downloading new script..."
wget -qO/mnt/root/arch_install_script_chroot.sh https://gist.github.com/fanfan54/b29cd16611eebb9c343ecccf760e5a2e/raw/95ab81fce3ee583c227561867e1ba4d8167f86f4/arch_install_script_chroot.sh
chmod 755 /mnt/root/arch_install_script_chroot.sh

arch-chroot /mnt /root/arch_install_script_chroot.sh

echo "> Deleting junk files..."
rm /mnt/root/arch_install_script_chroot.sh

echo "Done. Rebooting in 10 seconds..."
sleep 10
echo "> Rebooting..."
reboot
