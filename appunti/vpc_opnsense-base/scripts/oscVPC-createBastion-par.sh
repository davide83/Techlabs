#!/bin/bash

# EU - France
# Paris - EU-WEST-PAR 3AZ
export OS_REGION_NAME=EU-WEST-PAR
VPC_REGION_NAME=PAR
# OPN nets
VPC_NET_OPN_GREEN=GREEN
VPC_SEGMENT_GREEN_ID=2042
VPC_NET_OPN_RED=RED
VPC_SEGMENT_RED_ID=0
VPC_NET_OPN_ORANGE=ORANGE
VPC_SEGMENT_ORANGE_ID=2044
VPC_NET_OPN_BLUE=BLUE
VPC_SEGMENT_BLUE_ID=2045
VPC_NET_OPN_PINK=PINK
VPC_SEGMENT_PINK_ID=2046

# VPC_ZONE
#VPC_ZONE=eu-west-par-b
VPC_ZONE=$1

# Import SSH public key to os region as trusted keypair
VPC_SSHKEY_NAME=vpc-techlab_rsa

# Get the regional segmented privateNetwork ID
VPC_NET_GREEN_NAME=pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_NET_OPN_GREEN-$VPC_SEGMENT_GREEN_ID
VPC_NET_GREEN_ID=$(openstack network show "$VPC_NET_GREEN_NAME" -c id -f value)
echo "$VPC_NET_GREEN_NAME id: $VPC_NET_GREEN_ID"
VPC_NET_RED_NAME=pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_NET_OPN_RED-$VPC_SEGMENT_RED_ID
VPC_NET_RED_ID=$(openstack network show $VPC_NET_RED_NAME -c id -f value)
echo "$VPC_NET_RED_NAME id: $VPC_NET_RED_ID"
VPC_NET_ORANGE_NAME=pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_NET_OPN_ORANGE-$VPC_SEGMENT_ORANGE_ID
VPC_NET_ORANGE_ID=$(openstack network show "$VPC_NET_ORANGE_NAME" -c id -f value)
echo "$VPC_NET_ORANGE_NAME id: $VPC_NET_ORANGE_ID"
VPC_NET_BLUE_NAME=pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_NET_OPN_BLUE-$VPC_SEGMENT_BLUE_ID
VPC_NET_BLUE_ID=$(openstack network show "$VPC_NET_BLUE_NAME" -c id -f value)
echo "$VPC_NET_BLUE_NAME id: $VPC_NET_BLUE_ID"
VPC_NET_PINK_NAME=pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_NET_OPN_PINK-$VPC_SEGMENT_PINK_ID
VPC_NET_PINK_ID=$(openstack network show "$VPC_NET_PINK_NAME" -c id -f value)
echo "$VPC_NET_PINK_NAME id: $VPC_NET_PINK_ID"


# CREATE Bastion Host
#OPN_VM_IMAGE_NAME='OPNsense-25.1-ufs-efi-vm-amd64'
#OPN_VM_IMAGE_NAME='OPNsense-25.1-ufs-serial-vm-amd64'
VPC_BASTION_NAME="bastion-$VPC_REGION_NAME-VPC_opnsense"
echo "CREATING VPC_BASTION_NAME: $VPC_BASTION_NAME"

openstack server create \
  --description "Bastion Host (VPC_opnsense-base) in $VPC_REGION_NAME" \
  --image "Ubuntu 22.04" \
  --flavor c3-4 \
  --network $VPC_NET_GREEN_ID \
  --network "Ext-Net" \
  --availability-zone $VPC_ZONE \
  --key-name $VPC_SSHKEY_NAME \
  $VPC_BASTION_NAME

echo "BASTION $VPC_BASTION_NAME CREATED!"
