#!/bin/bash
echo "[B-SAD-200_my-web part 2] auto installer for Debian in my-client (for Fedora 28/29)"
echo "Authors: francois.lefevre@epitech.eu laurent.gelard@epitech.eu"
echo "-----"

if [ $# -ne 1 ]; then  
    echo "> Downloading Debian ISO netinstall..."
    mkdir -p iso/
    wget -oiso/debian-9.8.0-amd64-netinst.iso https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.8.0-amd64-netinst.iso
    iso="iso/debian-9.8.0-amd64-netinst.iso"
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

echo "== Checking the existing VM for my-client..."
echo "> Checking if the image file already exists..."
if [ ! -f "images/sad-my_web-client.img" ]; then
    echo "Error: image file not found. Please run install_archlinux first."
    exit 1
fi

echo "> Destroy (kill) VM for my-client using virsh..."
virsh destroy --domain B-SAD-200_my-client_francois.lefevre
echo "> Undefine (delete) VM for my-client using virsh..."
virsh undefine --domain B-SAD-200_my-client_francois.lefevre --nvram
echo "> Re-creating VM for my-client using virt-install and Debian ISO at $iso (specs: UEFI, 2GB of RAM, 32GB of hard drive (that contains Arch Linux), network bridge, graphics via VNC on 127.0.0.1:5901)..."
virt-install -n"B-SAD-200_my-client_francois.lefevre" --memory=2048 --disk path=images/sad-my_web-client.img,size=32 --network bridge=virbr0 --graphics vnc,listen=127.0.0.1,port=5901 --cdrom $iso --noautoconsole --boot uefi
echo "== Done re-creating VM for my-client"

echo "> Starting VNC client for my-client (in background)..."
vncviewer 127.0.0.1:5901 > /dev/null 2>&1 &

echo "Done."
