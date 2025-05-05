#!/bin/bash

# Create the regional segmented privateNetwork
openstack network create \
    --provider-network-type vrack \
    --provider-segment $VPC_SEGMENT_ID \
    --disable-port-security \
    --description "Techlabs' VPC_opnsense-base (vlan_id: $VPC_SEGMENT_ID / $VPC_SEGMENT_NAME) privateNetwork in $VPC_REGION_NAME" \
    $VPC_NET_NAME

# Create the regional PINK Subnet 192-168-66-0_24
VPC_SUBNET_NAME=pnSbnt-VPC_opnsense-$VPC_REGION_NAME-$VPC_SEGMENT_NAME-$VPC_SEGMENT_ID-192-168-66-0_24
openstack subnet create \
    --description "Techlabs' VPC_opnsense-base (vlan_id: $VPC_SEGMENT_ID / $VPC_SEGMENT_NAME) Private Subnet 192.168.66.0/24 in $VPC_REGION_NAME region" \
    --network $VPC_NET_NAME \
    --subnet-range 192.168.66.0/24 \
    --dhcp \
    --allocation-pool start=192.168.66.96,end=192.168.66.254 \
    --gateway none \
    $VPC_SUBNET_NAME
