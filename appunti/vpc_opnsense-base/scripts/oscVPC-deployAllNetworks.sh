#!/bin/bash

#############################################
#        oscVPC-deployAllNetworks.sh        #
#############################################
#     Input parameters                      #
# (1) VPC_REGION_NAME - required            #
#     One of this: [PAR|MIL|GRA|LIM]        #
#############################################
# Examples:
# $ ./oscVPC-deployAllOPNs.sh <VPC_REGION_NAME>
#

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
    MIL) echo "WARNING - Input VPC_REGION_NAME=MIL not allowed yet - Must be in [PAR|GRA]"
    TESTRESULT=3
    exit $TESTRESULT;;
    ## VPC BASTION 2 - LIM
    LIM) echo "WARNING - Input VPC_REGION_NAME=LIM not allowed yet - Must be in [PAR|GRA]"
    TESTRESULT=3
    exit $TESTRESULT;;
    GRA) echo "DEPLOYING VPC opnsenseNETWORKs IN $VPC_REGION_NAME ..."
    ## (EU) Gravelines, Francia - GRA9/GRA11 (1AZ)
    export OS_REGION_NAME=GRA9
    export VPC_REGION_NAME=GRA
    ## VPC NET 1 - GREEN (LAN | 2062)
    export VPC_SEGMENT_NAME=GREEN
    export VPC_SEGMENT_ID=2062
    export VPC_NET_NAME="pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_SEGMENT_NAME-$VPC_SEGMENT_ID"
    echo "DEPLOYING VPC opnsense $VPC_SEGMENT_NAME segment as $VPC_SEGMENT_ID..."
    scripts/oscVPC-createNetwork-gra-GREEN.sh
    echo "\!/ CHECK IF segment $VPC_SEGMENT_NAME WAS DEPLOYED IN $VPC_REGION_NAME as $VPC_SEGMENT_ID SUCCESSFUL \!/"
    ## VPC NET 2 - RED (WAN | 0)
    export VPC_SEGMENT_NAME=RED
    export VPC_SEGMENT_ID=0
    export VPC_NET_NAME="pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_SEGMENT_NAME-$VPC_SEGMENT_ID"
    echo "DEPLOYING VPC opnsense $VPC_SEGMENT_NAME segment as $VPC_SEGMENT_ID..."
    scripts/oscVPC-createNetwork-gra-RED.sh
    echo "\!/ CHECK IF segment $VPC_SEGMENT_NAME WAS DEPLOYED IN $VPC_REGION_NAME as $VPC_SEGMENT_ID SUCCESSFUL \!/"
    ## VPC NET 3 - ORANGE (DMZ | 2064)
    export VPC_SEGMENT_NAME=ORANGE
    export VPC_SEGMENT_ID=2064
    export VPC_NET_NAME="pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_SEGMENT_NAME-$VPC_SEGMENT_ID"
    echo "DEPLOYING VPC opnsense $VPC_SEGMENT_NAME segment as $VPC_SEGMENT_ID..."
    scripts/oscVPC-createNetwork-gra-ORANGE.sh
    echo "\!/ CHECK IF segment $VPC_SEGMENT_NAME WAS DEPLOYED IN $VPC_REGION_NAME as $VPC_SEGMENT_ID SUCCESSFUL \!/"
    ## VPC NET 4 - BLUE (VPN | 2065)
    export VPC_SEGMENT_NAME=BLUE
    export VPC_SEGMENT_ID=2065
    export VPC_NET_NAME="pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_SEGMENT_NAME-$VPC_SEGMENT_ID"
    echo "DEPLOYING VPC opnsense $VPC_SEGMENT_NAME segment as $VPC_SEGMENT_ID..."
    scripts/oscVPC-createNetwork-gra-BLUE.sh
    echo "\!/ CHECK IF segment $VPC_SEGMENT_NAME WAS DEPLOYED IN $VPC_REGION_NAME as $VPC_SEGMENT_ID SUCCESSFUL \!/"
    ## VPC NET 5 - PINK (CARP | 2066)
    export VPC_SEGMENT_NAME=PINK
    export VPC_SEGMENT_ID=2066
    export VPC_NET_NAME="pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_SEGMENT_NAME-$VPC_SEGMENT_ID"
    echo "DEPLOYING VPC opnsense $VPC_SEGMENT_NAME segment as $VPC_SEGMENT_ID..."
    scripts/oscVPC-createNetwork-gra-PINK.sh
    echo "\!/ CHECK IF segment $VPC_SEGMENT_NAME WAS DEPLOYED IN $VPC_REGION_NAME as $VPC_SEGMENT_ID SUCCESSFUL \!/"
    echo "\!/ CHECK IF VPC opnsenseNETWORKs WERE DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"
    TESTRESULT=0
    exit $TESTRESULT;;
    PAR) echo "DEPLOYING VPC opnsenseNETWORKs IN $VPC_REGION_NAME ..."
    ## (EU) Parigi, Francia - EU-WEST-PAR (3AZ)
    export OS_REGION_NAME=EU-WEST-PAR
    export VPC_REGION_NAME=PAR   
    ## VPC NET 1 - GREEN (LAN | 2042)
    export VPC_SEGMENT_NAME=GREEN
    export VPC_SEGMENT_ID=2042
    export VPC_NET_NAME="pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_SEGMENT_NAME-$VPC_SEGMENT_ID"
    echo "DEPLOYING VPC opnsense $VPC_SEGMENT_NAME segment as $VPC_SEGMENT_ID..."
    scripts/oscVPC-createNetwork-par-GREEN.sh
    echo "\!/ CHECK IF segment $VPC_SEGMENT_NAME WAS DEPLOYED IN $VPC_REGION_NAME as $VPC_SEGMENT_ID SUCCESSFUL \!/"
    ## VPC NET 2 - RED (WAN | 0)
    export VPC_SEGMENT_NAME=RED
    export VPC_SEGMENT_ID=0
    export VPC_NET_NAME="pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_SEGMENT_NAME-$VPC_SEGMENT_ID"
    echo "DEPLOYING VPC opnsense $VPC_SEGMENT_NAME segment as $VPC_SEGMENT_ID..."
    scripts/oscVPC-createNetwork-par-RED.sh
    echo "\!/ CHECK IF segment $VPC_SEGMENT_NAME WAS DEPLOYED IN $VPC_REGION_NAME as $VPC_SEGMENT_ID SUCCESSFUL \!/"
    ## VPC NET 3 - ORANGE (DMZ | 2044)
    export VPC_SEGMENT_NAME=ORANGE
    export VPC_SEGMENT_ID=2044
    export VPC_NET_NAME="pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_SEGMENT_NAME-$VPC_SEGMENT_ID"
    echo "DEPLOYING VPC opnsense $VPC_SEGMENT_NAME segment as $VPC_SEGMENT_ID..."
    scripts/oscVPC-createNetwork-par-ORANGE.sh
    echo "\!/ CHECK IF segment $VPC_SEGMENT_NAME WAS DEPLOYED IN $VPC_REGION_NAME as $VPC_SEGMENT_ID SUCCESSFUL \!/"
    ## VPC NET 4 - BLUE (VPN | 2045)
    export VPC_SEGMENT_NAME=BLUE
    export VPC_SEGMENT_ID=2045
    export VPC_NET_NAME="pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_SEGMENT_NAME-$VPC_SEGMENT_ID"
    echo "DEPLOYING VPC opnsense $VPC_SEGMENT_NAME segment as $VPC_SEGMENT_ID..."
    scripts/oscVPC-createNetwork-par-BLUE.sh
    echo "\!/ CHECK IF segment $VPC_SEGMENT_NAME WAS DEPLOYED IN $VPC_REGION_NAME as $VPC_SEGMENT_ID SUCCESSFUL \!/"
    ## VPC NET 5 - PINK (CARP | 2046)
    export VPC_SEGMENT_NAME=PINK
    export VPC_SEGMENT_ID=2046
    export VPC_NET_NAME="pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_SEGMENT_NAME-$VPC_SEGMENT_ID"
    echo "DEPLOYING VPC opnsense $VPC_SEGMENT_NAME segment as $VPC_SEGMENT_ID..."
    scripts/oscVPC-createNetwork-par-PINK.sh
    echo "\!/ CHECK IF segment $VPC_SEGMENT_NAME WAS DEPLOYED IN $VPC_REGION_NAME as $VPC_SEGMENT_ID SUCCESSFUL \!/"
    echo "\!/ CHECK IF VPC opnsenseNETWORKs WERE DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"
    TESTRESULT=0
    exit $TESTRESULT;;
    *) echo "ERROR - Input VPC_REGION_NAME not allowed - Must be in [MIL|LIM|PAR|GRA]"
    ## ALL(*) 
    TESTRESULT=2
    exit $TESTRESULT;;
esac