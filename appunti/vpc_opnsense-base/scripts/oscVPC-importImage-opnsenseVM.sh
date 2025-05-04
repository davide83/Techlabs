#!/bin/bash

# Set OPN VM_IMAGE vars
# *ovh
OPN_VM_IMAGE_VERSION=25.1 # 24.7.12|25.1
OPN_VM_IMAGE_ARCH=amd64 # amd64*|aarch64
OPN_VM_IMAGE_CONSOLE=efi # efi*|serial*
OPN_VM_IMAGE_DISK_FORMAT=qcow2 # vhdx|qcow2*

# Set OPN TMP DIRECTORY vars
OPN_TMP_DIRECTORY=/tmp/opnsense-images

# Set OPN TMP FILE vars
OPN_TMP_FILE_QCOW2=$OPN_TMP_DIRECTORY/OPNsense-$OPN_VM_IMAGE_VERSION-ufs-$OPN_VM_IMAGE_CONSOLE-vm-$OPN_VM_IMAGE_ARCH.qcow2

# IMPORT VM IMAGE
openstack image create \
    --container-format bare \
    --disk-format $OPN_VM_IMAGE_DISK_FORMAT \
    --file $OPN_TMP_FILE_QCOW2 \
    OPNsense-$OPN_VM_IMAGE_VERSION-ufs-$OPN_VM_IMAGE_CONSOLE-vm-$OPN_VM_IMAGE_ARCH
