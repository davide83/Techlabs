#!/bin/bash

# Set OPN VM_IMAGE
# *ovh
OPN_VM_IMAGE_VERSION=25.1 # 24.7.12|25.1
OPN_VM_IMAGE_ARCH=amd64 # amd64*|aarch64
OPN_VM_IMAGE_CONSOLE=efi # efi*|serial*
OPN_VM_IMAGE_DISK_FORMAT=qcow2 # vhdx|qcow2*

# Set OPN VM IMAGE URL
OPN_VM_IMAGE_URL="https://github.com/maurice-w/opnsense-vm-images/releases/download/$OPN_VM_IMAGE_VERSION/OPNsense-$OPN_VM_IMAGE_VERSION-ufs-$OPN_VM_IMAGE_CONSOLE-vm-$OPN_VM_IMAGE_ARCH.$OPN_VM_IMAGE_DISK_FORMAT.bz2"

# Set OPN TMP DIRECTORY vars
OPN_TMP_DIRECTORY=/tmp/opnsense-images
if [ ! -d "$OPN_TMP_DIRECTORY" ]; then
    #echo "$OPN_TMP_DIRECTORY does not exist."
    mkdir -p $OPN_TMP_DIRECTORY
fi

# Set OPN TMP FILE vars
OPN_TMP_FILE_BZ2=$OPN_TMP_DIRECTORY/OPNsense-$OPN_VM_IMAGE_VERSION-ufs-$OPN_VM_IMAGE_CONSOLE-vm-$OPN_VM_IMAGE_ARCH.$OPN_VM_IMAGE_DISK_FORMAT.bz2

# Echo
echo "ECHO .> Downloading $OPN_VM_IMAGE_URL"

# Get OPN VM IMAGE (BZ2)
wget \
    -O $OPN_TMP_FILE_BZ2 \
    --no-check-certificate \
    $OPN_VM_IMAGE_URL

# Echo
echo "ECHO .> $OPN_TMP_FILE_BZ2 Downloaded!"

# Extract OPN_TMP_FILE_BZ2 to OPN_TMP_FILE_$OPN_VM_IMAGE_DISK_FORMAT

# Echo
echo "ECHO .> Extracting $OPN_TMP_FILE_BZ2"

ORIGIN_ROOT_PATH=$(pwd)
cd $OPN_TMP_DIRECTORY
bzip2 -d $OPN_TMP_FILE_BZ2
cd $ORIGIN_ROOT_PATH

# Set OPN TMP FILE vars
OPN_TMP_FILE_QCOW2=$OPN_TMP_DIRECTORY/OPNsense-$OPN_VM_IMAGE_VERSION-ufs-$OPN_VM_IMAGE_CONSOLE-vm-$OPN_VM_IMAGE_ARCH.qcow2

# Echo
echo "ECHO .> $OPN_TMP_FILE_QCOW2 Extracted!"