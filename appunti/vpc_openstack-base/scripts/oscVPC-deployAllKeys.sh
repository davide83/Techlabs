#!/bin/bash

### VPC SSHKEYS
VPC_SSHKEY_NAME=vpc-techlab_rsa
VPC_SSHKEY_FILENAME=~/.ssh/vpcTechlab_rsa
#ssh-keygen -t rsa -b 4096 -f $VPC_SSHKEY_FILENAME
#openstack keypair create --public-key <VPC_SSHKEY_FILENAME> <VPC_SSHKEY_NAME>

## VPC SSHKEY - LIM
export OS_REGION_NAME=DE1
VPC_REGION_NAME=LIM
echo "DEPLOYING SSHKEY IN $VPC_REGION_NAME ..."
# Import SSH public key to os region as trusted keypair
openstack keypair create \
    --public-key $VPC_SSHKEY_FILENAME.pub \
    $VPC_SSHKEY_NAME

echo "\!/ CHECK IF THE SSHKEY WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"

## VPC SSHKEY - GRA
export OS_REGION_NAME=GRA11
VPC_REGION_NAME=GRA
echo "DEPLOYING SSHKEY IN $VPC_REGION_NAME ..."
# Import SSH public key to os region as trusted keypair
openstack keypair create \
    --public-key $VPC_SSHKEY_FILENAME.pub \
    $VPC_SSHKEY_NAME

echo "\!/ CHECK IF THE SSHKEY WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"

## VPC SSHKEY - MIL
# export OS_REGION_NAME=EU-WEST-MIL
# VPC_REGION_NAME=MIL
# echo "DEPLOYING SSHKEY IN $VPC_REGION_NAME ..."
# # Import SSH public key to os region as trusted keypair
# openstack keypair create \
#     --public-key $VPC_SSHKEY_FILENAME.pub \
#     $VPC_SSHKEY_NAME
#
# echo "\!/ CHECK IF THE SSHKEY WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"

## VPC KESSHKEY - PAR
export OS_REGION_NAME=EU-WEST-PAR
VPC_REGION_NAME=PAR
echo "DEPLOYING SSHKEY IN $VPC_REGION_NAME ..."
# Import SSH public key to os region as trusted keypair
openstack keypair create \
    --public-key $VPC_SSHKEY_FILENAME.pub \
    $VPC_SSHKEY_NAME

echo "\!/ CHECK IF THE SSHKEY WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"