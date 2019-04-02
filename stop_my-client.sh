#!/bin/bash
echo "[B-SAD-200_my-web] auto installer in my-client (for Fedora 28/29)"
echo "Authors: francois.lefevre@epitech.eu laurent.gelard@epitech.eu"
echo "-----"

echo "> Stopping VM for my-client using virsh..."
virsh destroy --domain B-SAD-200_my-client_francois.lefevre

echo "Done."
