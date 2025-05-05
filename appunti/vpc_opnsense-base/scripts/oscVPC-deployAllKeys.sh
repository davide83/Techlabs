#!/bin/bash

#############################################
#          oscVPC-deployAllKeys.sh          #
#############################################
#     Input parameters                      #
# (1) VPC_REGION_NAME - required            #
#     One of this: [PAR|MIL|GRA|LIM]        #
#############################################
# Examples:
# $ ./oscVPC-deployAllKeys.sh <VPC_REGION_NAME>
#

### VPC SSHKEYS
VPC_SSHKEY_NAME=vpc-techlab_rsa
VPC_SSHKEY_FILENAME=~/.ssh/vpcTechlab_rsa
#ssh-keygen -t rsa -b 4096 -f $VPC_SSHKEY_FILENAME
#openstack keypair create --public-key <VPC_SSHKEY_FILENAME> <VPC_SSHKEY_NAME>

# Input parameters
VPC_REGION_NAME="${1}"

## Tests input parameters
TESTRESULT=0
# nb params
if [ $# -lt 1 -o $# -gt 2 ]
then
    echo "ERROR - Incorrect number of input parameters - Must be a VPC_REGION_NAME [PAR|MIL|GRA|LIM]"
    TESTRESULT=1
    exit $TESTRESULT
fi

# VPC_REGION_NAME
case $VPC_REGION_NAME in
    ## VPC BASTION 1 - MIL
    MIL) TESTRESULT=3
    echo "WARNING - Input VPC_REGION_NAME=MIL not allowed yet - Must be in [PAR|GRA|LIM]"
    exit $TESTRESULT;;
    ## VPC BASTION 2 - LIM
    LIM) VPC_REGION_NAME=LIM
    export OS_REGION_NAME=EU-WEST-PAR
    echo "DEPLOYING SSHKEY IN $VPC_REGION_NAME ..."
    # Import SSH public key to os region as trusted keypair
    openstack keypair create \
        --public-key $VPC_SSHKEY_FILENAME.pub \
        $VPC_SSHKEY_NAME
    echo "\!/ CHECK IF THE SSHKEY WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"
    TESTRESULT=0
    exit $TESTRESULT;;
    ## VPC BASTION 3 - GRA
    GRA) VPC_REGION_NAME=GRA
    export OS_REGION_NAME=EU-WEST-PAR
    echo "DEPLOYING SSHKEY IN $VPC_REGION_NAME ..."
    # Import SSH public key to os region as trusted keypair
    openstack keypair create \
        --public-key $VPC_SSHKEY_FILENAME.pub \
        $VPC_SSHKEY_NAME
    echo "\!/ CHECK IF THE SSHKEY WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"
    TESTRESULT=0
    exit $TESTRESULT;;
    ## VPC BASTION 4 - PAR
    PAR) VPC_REGION_NAME=PAR
    export OS_REGION_NAME=EU-WEST-PAR
    echo "DEPLOYING SSHKEY IN $VPC_REGION_NAME ..."
    # Import SSH public key to os region as trusted keypair
    openstack keypair create \
        --public-key $VPC_SSHKEY_FILENAME.pub \
        $VPC_SSHKEY_NAME
    echo "\!/ CHECK IF THE SSHKEY WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"
    TESTRESULT=0
    exit $TESTRESULT;;
    ## ALL(*)
    *) TESTRESULT=2
    echo "ERROR - Input VPC_REGION_NAME not allowed - Must be in [MIL|LIM|PAR|GRA]"
    exit $TESTRESULT;;
esac
