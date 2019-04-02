#!/bin/bash
echo "[B-SAD-200_my-web] auto installer in my-web (for Fedora 28/29)"
echo "Authors: francois.lefevre@epitech.eu laurent.gelard@epitech.eu"
echo "-----"

echo "> Stopping VM for my-web using virsh..."
virsh destroy --domain B-SAD-200_my-web_francois.lefevre
echo "> Deleting VM for my-client using virsh..."
virsh undefine --domain B-SAD-200_my-web_francois.lefevre --nvram
echo "> Deleting image file..."
rm -rf images/sad-my_web-web.img

echo "Done."
