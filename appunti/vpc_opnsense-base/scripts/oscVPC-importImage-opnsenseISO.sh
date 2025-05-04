#!/bin/bash

# Set OPN VM_IMAGE vars
# *ovh
OPN_ISO_IMAGE_VERSION=25.1 # 24.7.12|25.1|
OPN_ISO_IMAGE_ARCH=amd64 # amd64*|aarch64
OPN_ISO_IMAGE_CONSOLE=dvd # nano|dvd*|vga|serial
OPN_ISO_IMAGE_DISK_FORMAT=iso # iso*

# Set OPN TMP DIRECTORY vars
OPN_TMP_DIRECTORY=/tmp/opnsense-images

# Set OPN TMP FILE vars
OPN_TMP_FILE_ISO=$OPN_TMP_DIRECTORY/OPNsense-$OPN_ISO_IMAGE_VERSION-$OPN_ISO_IMAGE_CONSOLE-$OPN_ISO_IMAGE_ARCH.iso

# Echo
echo "ECHO .> Importing..."

# IMPORT VM IMAGE
openstack image create \
    --container-format bare \
    --disk-format $OPN_VM_IMAGE_DISK_FORMAT \
    --file $OPN_TMP_FILE_ISO \
    OPNsense-$OPN_ISO_IMAGE_VERSION.$OPN_ISO_IMAGE_DISK_FORMAT

# Echo
echo "ECHO .> OPNsense-$OPN_VM_IMAGE_VERSION-ufs-$OPN_VM_IMAGE_CONSOLE-vm-$OPN_VM_IMAGE_ARCH Imported!"