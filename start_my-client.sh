#!/bin/bash
echo "[B-SAD-200_my-web] auto installer in my-client (for Fedora 28/29)"
echo "Authors: francois.lefevre@epitech.eu laurent.gelard@epitech.eu"
echo "-----"

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
echo "> Destroy (kill) VM for my-client using virsh if already exists..."
virsh destroy --domain B-SAD-200_my-client_francois.lefevre
echo "> Undefine (delete) VM for my-client using virsh if already exists..."
virsh undefine --domain B-SAD-200_my-client_francois.lefevre --nvram
echo "> Creating VM for my-client using virt-install at $1 (specs: UEFI, 2GB of RAM, 32GB of hard drive, network bridge, graphics via VNC on 127.0.0.1:5901)..."
virt-install -n"B-SAD-200_my-client_francois.lefevre" --memory=2048 --disk path=images/sad-my_web-client.img,size=32 --network bridge=virbr0 --graphics vnc,listen=127.0.0.1,port=5901 --noautoconsole --boot uefi
echo "== Done creating VM for my-client"

echo "> Starting VNC client for my-client (in background)..."
vncviewer 127.0.0.1:5901 > /dev/null 2>&1 &

echo "Done."
