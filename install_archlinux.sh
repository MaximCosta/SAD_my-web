#!/bin/bash
echo "[B-SAD-200_my-web part 1] auto installer for Arch Linux in my-client (for Fedora 28/29)"
echo "Authors: francois.lefevre@epitech.eu laurent.gelard@epitech.eu"
echo "-----"

if [ $# -ne 1 ]; then  
    echo "> Downloading Arch Linux ISO 2019.03.01..."
    mkdir -p iso/
    wget -oiso/archlinux-2019.03.01-x86_64.iso http://mir.archlinux.fr/iso/2019.03.01/archlinux-2019.03.01-x86_64.iso
    iso="iso/archlinux-2019.03.01-x86_64.iso"
else
    iso=$1
fi

echo "== Installing software prerequisites... (needs sudo)"
echo "> Installing virtualization support from Fedora repositories..."
sudo dnf -y group install --with-optional virtualization
echo "> Starting service libvirtd..."
sudo systemctl start libvirtd
echo "> Installing TigerVNC..."
sudo dnf -y install tigervnc
echo "== Done installing prerequisites."

echo "== Creating VM for my-client..."
echo "> Creating sparse raw image file (max. 32 GB) for my-client..."
mkdir -p images/
if [ -f "images/sad-my_web-client.img" ]; then
    echo "/!\ Skipped. File already exists."
else
    truncate --size=32000M images/sad-my_web-client.img
fi
echo "> Destroy (kill) VM for my-client using virsh if already exists..."
virsh destroy --domain B-SAD-200_my-client_francois.lefevre
echo "> Undefine (delete) VM for my-client using virsh if already exists..."
virsh undefine --domain B-SAD-200_my-client_francois.lefevre --nvram
echo "> Creating VM for my-client using virt-install and Arch Linux ISO at $iso (specs: UEFI, 2GB of RAM, 32GB of hard drive, network bridge, graphics via VNC on 127.0.0.1:5901)..."
virt-install -n"B-SAD-200_my-client_francois.lefevre" --memory=2048 --disk path=images/sad-my_web-client.img,size=32 --network bridge=virbr0 --graphics vnc,listen=127.0.0.1,port=5901 --cdrom $iso --noautoconsole --boot uefi
echo "== Done creating VM for my-client"

echo "> Starting VNC client for my-client (in background)..."
vncviewer 127.0.0.1:5901 > /dev/null 2>&1 &

echo "Done."
echo "[i] To continue installation, please type these commands in the VNC window:"
echo
echo "- loadkeys fr-latin1 (as your keyboard will be mapped to QWERTY, type loqdkeys fr)lqtin&"
echo "- wget -qO- https://bit.ly/install-arch-on-my-client | bash -"
exit 0
