#!/bin/bash
#############################################
#          oscVPC-deployAllOPNs.sh          #
#############################################
#     Input parameters                      #
# (1) VPC_REGION_NAME - required            #
#     One of this: [PAR|MIL|GRA|LIM]        #
# (2) IS_HA_BOOL - required                 #
#     One of this: [false|true]             #
#############################################
# Examples:
# $ ./oscVPC-deployAllOPNs.sh <VPC_REGION_NAME> false # it will provision one OPNsense instance with a 3rd nic ready for ha
#
# $ ./oscVPC-deployAllOPNs.sh <VPC_REGION_NAME> true # it will provision two OPNsense instances
#

# Input parameters
VPC_REGION_NAME="${1}"
IS_HA_BOOL="${2}"

## Tests input parameters
TESTRESULT=0
# nb params
if [ $# -lt 1 -o $# -gt 3 ]
then
    echo "ERROR - Incorrect number of input parameters - Must be two: VPC_REGION_NAME [PAR|MIL|GRA|LIM] and IS_HA_BOOL [false|true]"
    TESTRESULT=1
    exit $TESTRESULT
fi

# VPC_REGION_NAME
case $VPC_REGION_NAME in
    ## VPC OPN HA 1 - MIL
    MIL) TESTRESULT=3
    echo "WARNING - Input VPC_REGION_NAME=MIL not allowed yet - Must be in [PAR|GRA]"
    exit $TESTRESULT;;
    ## VPC OPN HA 2 - LIM
    LIM) TESTRESULT=3
    echo "WARNING - Input VPC_REGION_NAME=LIM not supported yet - Must be in [PAR|GRA]"
    exit $TESTRESULT;;
    ## VPC OPN HA 3 - GRA
    GRA) echo ""
    echo ""
    if [ "$IS_HA_BOOL" == true ]; then
        echo "### OPNsense single node .>"
        VPC_OPN_NODE_ID=1
        echo "DEPLOYING OPNSENSE node$VPC_OPN_NODE_ID IN $VPC_REGION_NAME mono zone"
        scripts/oscVPC-createOPN-gra.sh $VPC_OPN_NODE_ID
        echo "\!/ CHECK IF OPNSENSE WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"
        VPC_OPN_NODE_ID=2
        echo "DEPLOYING OPNSENSE node$VPC_OPN_NODE_ID IN $VPC_REGION_NAME mono zone"
        scripts/oscVPC-createOPN-gra.sh $VPC_OPN_NODE_ID
        echo "\!/ CHECK IF OPNSENSE WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"
    else
        echo "### OPNsense ha nodes .>"
        VPC_OPN_NODE_ID=1
        echo "DEPLOYING OPNSENSE node$VPC_OPN_NODE_ID IN $VPC_REGION_NAME mono zone"
        scripts/oscVPC-createOPN-gra.sh $VPC_OPN_NODE_ID
        echo "\!/ CHECK IF OPNSENSE WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"
    fi
    TESTRESULT=0
    exit $TESTRESULT;;
    ## VPC OPN HA 4 - PAR
    PAR) echo ""
    echo ""
    if [ "$IS_HA_BOOL" == true ]; then
        echo "### OPNsense single node .>"
        VPC_OPN_NODE_ID=1
        VPC_ZONE=eu-west-par-a
        echo "DEPLOYING OPNSENSE node$VPC_OPN_NODE_ID IN $VPC_REGION_NAME on $VPC_ZONE zone"
        scripts/oscVPC-createOPN-par.sh $VPC_OPN_NODE_ID $VPC_ZONE
        echo "\!/ CHECK IF OPNSENSE WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"
        VPC_OPN_NODE_ID=2
        VPC_ZONE=eu-west-par-b
        echo "DEPLOYING OPNSENSE node$VPC_OPN_NODE_ID IN $VPC_REGION_NAME on $VPC_ZONE zone"
        scripts/oscVPC-createOPN-par.sh $VPC_OPN_NODE_ID $VPC_ZONE
        echo "\!/ CHECK IF OPNSENSE WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"
    else
        echo "### OPNsense ha nodes .>"
        VPC_OPN_NODE_ID=1
        VPC_ZONE=eu-west-par-a
        echo "DEPLOYING OPNSENSE node$VPC_OPN_NODE_ID IN $VPC_REGION_NAME on $VPC_ZONE zone"
        scripts/oscVPC-createOPN-par.sh $VPC_OPN_NODE_ID $VPC_ZONE
        echo "\!/ CHECK IF OPNSENSE WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"
    fi
    TESTRESULT=0
    exit $TESTRESULT;;
    ## ALL(*)
    *) TESTRESULT=2
    echo "ERROR - Input VPC_REGION_NAME not allowed - Must be in [MIL|LIM|PAR|GRA]"
    exit $TESTRESULT;;
esac
