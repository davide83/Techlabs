#!/bin/bash

# EU - France
# Paris - EU-WEST-PAR 3AZ
export OS_REGION_NAME=EU-WEST-PAR
VPC_REGION_NAME=PAR
VPC_SEGMENT_ID=3042

# Import SSH public key to os region as trusted keypair
VPC_SSHKEY_NAME=vpc-techlab_rsa

# Get the regional segmented privateNetwork ID
VPC_NET_NAME=pn-vlan_id_$VPC_SEGMENT_ID-techlabVPC
VPC_NET_ID=$(openstack network show $VPC_NET_NAME -c id -f value)

# GET SUBNET ID from a private subnet name such as techlabVPCvlan$VPC_SEGMENT_ID-sbnt$VPC_REGION_NAME-172-30-16-0_20
#VPC_SUBNET_NAME=techlabVPCvlan$VPC_SEGMENT_ID-sbnt$VPC_REGION_NAME-172-30-16-0_20
#VPC_SUBNET_ID=$(openstack subnet show $VPC_SUBNET_NAME -c id -f value)

# CREATE Bastion Host
VPC_BASTION_NAME=bastion-VPC-$VPC_SEGMENT_ID-$VPC_REGION_NAME

openstack server create \
  --description "Bastion Host $VPC_NET_NAME $VPC_REGION_NAME" \
  --flavor c3-4 \
  --image "Ubuntu 22.04" \
  --network $VPC_NET_ID \
  --key-name $VPC_SSHKEY_NAME \
  $VPC_BASTION_NAME

VPC_BASTION_ID=$(openstack server show $VPC_BASTION_NAME -c id -f value)
echo "VPC Bastion ID: $VPC_BASTION_ID"

# PASS OR CREATE Bastion Host IPv4 as Floating IP 
VPC_BASTION_FIP_ID=$(openstack floating ip create Ext-Net -c id -f value)
VPC_BASTION_FIP_NAME=$(openstack floating ip show $VPC_BASTION_FIP_ID -c name -f value)
VPC_BASTION_FIP_IPv4=$VPC_BASTION_FIP_NAME

# Attach BASTION_FIP_IPv4 to Bastion Host instance
openstack server add floating ip $VPC_BASTION_ID $VPC_BASTION_FIP_IPv4

# End
echo "VPC Bastion FIP: $VPC_BASTION_FIP_IPv4"
