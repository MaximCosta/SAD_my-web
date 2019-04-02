#!/bin/bash
echo "[B-SAD-200_my-web part 3] auto installer for Ubuntu Server in my-web (for Fedora 28/29)"
echo "Authors: francois.lefevre@epitech.eu laurent.gelard@epitech.eu"
echo "-----"

if [ $# -ne 1 ]; then
    echo "> Downloading Ubuntu Server ISO 18.04.2..."
    mkdir -p iso/
    wget -oiso/ubuntu-18.04.2-live-server-amd64.iso http://releases.ubuntu.com/18.04.2/ubuntu-18.04.2-live-server-amd64.iso
    iso="iso/ubuntu-18.04.2-live-server-amd64.iso"
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

echo "== Creating VM for my-web..."
echo "> Creating sparse raw image file (max. 16 GB) for my-client..."
mkdir -p images/
if [ -e "images/sad-my_web-web.img" ]; then
    echo "/!\ Skipped. File already exists."
else
    truncate --size=16000M images/sad-my_web-web.img
fi
echo "> Destroy (kill) VM for my-web using virsh if already exists..."
virsh destroy --domain B-SAD-200_my-web_francois.lefevre
echo "> Undefine (delete) VM for my-web using virsh if already exists..."
virsh undefine --domain B-SAD-200_my-web_francois.lefevre --nvram
echo "> Creating VM for my-web using virt-install and Ubuntu Server ISO at $iso (specs: UEFI, 2GB of RAM, 16GB of hard drive, network bridge, graphics via VNC on 127.0.0.1:5902)..."
virt-install -n"B-SAD-200_my-web_francois.lefevre" --memory=2048 --disk path=images/sad-my_web-web.img,size=16 --network bridge=virbr0 --graphics vnc,listen=127.0.0.1,port=5902 --cdrom $iso --noautoconsole --boot uefi
echo "== Done creating VM for my-web"

echo "> Starting VNC client for my-web (in background)..."
vncviewer 127.0.0.1:5902 > /dev/null 2>&1 &

echo "Done."
