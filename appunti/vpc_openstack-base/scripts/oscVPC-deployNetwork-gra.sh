#!/bin/bash

# EU - France
# Gravelines - GRA11 1AZ
export OS_REGION_NAME=GRA11
VPC_REGION_NAME=GRA
VPC_SEGMENT_ID=3042

# Create the regional segmented privateNetwork
VPC_NET_NAME=pn-vlan_id_$VPC_SEGMENT_ID-techlabVPC
openstack network create \
    --provider-network-type vrack \
    --provider-segment $VPC_SEGMENT_ID \
    --description "Techlabs' VPC (vlan$VPC_SEGMENT_ID) privateNetwork in $VPC_REGION_NAME" \
    $VPC_NET_NAME

# Create the regional Router
VPC_ROUTER_NAME=router-$VPC_REGION_NAME-ExtGateway-techlabVPC
openstack router create \
    --description "Techlabs' VPC (vlan$VPC_SEGMENT_ID) Router in $VPC_REGION_NAME region" \
    $VPC_ROUTER_NAME
# Get Router ID
VPC_ROUTER_ID=`openstack router list -c Name -c ID -f value | grep $VPC_ROUTER_NAME  | grep -o '^[^ ]*'`

# Create the regional Subnet 10-42-32-0_24
VPC_SUBNET_NAME=pnSbnt-$VPC_SEGMENT_ID-$VPC_REGION_NAME-10-42-32-0_24
openstack subnet create \
    --description "Techlabs' VPC (vlan id $VPC_SEGMENT_ID) Private Subnet 10.42.32.0/24 in $VPC_REGION_NAME region" \
    --network $VPC_NET_NAME \
    --subnet-range 10.42.32.0/24 \
    --dhcp \
    --allocation-pool start=10.42.32.64,end=10.42.32.254 \
    --gateway 10.42.32.1 \
    --dns-nameserver 213.186.33.99 \
    --dns-nameserver 1.1.1.1 \
    --dns-nameserver 8.8.8.8 \
    --host-route destination=10.42.16.0/24,gateway=10.42.16.1 \
    --host-route destination=10.42.48.0/24,gateway=10.42.48.1 \
    --host-route destination=10.42.64.0/24,gateway=10.42.64.1 \
    $VPC_SUBNET_NAME
# Get Subnet ID
VPC_SUBNET_ID=`openstack subnet list -c Name -c ID -f value | grep $VPC_SUBNET_NAME  | grep -o '^[^ ]*'`
# Add the Subnet1 to the Router
openstack router add subnet $VPC_ROUTER_ID \
    $VPC_SUBNET_ID

# Set the Ext-Net as external gateway to the Router
openstack router set --external-gateway Ext-Net \
    $VPC_ROUTER_ID
