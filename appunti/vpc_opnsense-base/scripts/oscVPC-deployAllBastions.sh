#!/bin/bash
#############################################
#        oscVPC-deployAllBastions.sh        #
#############################################
#     Input parameters                      #
# (1) VPC_REGION_NAME - required            #
#     One of this: [PAR|MIL|GRA|LIM]        #
#############################################
# Examples:
# $ ./oscVPC-deployAllBastions.sh <VPC_REGION_NAME>
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
    MIL) TESTRESULT=3
    echo "WARNING - Input VPC_REGION_NAME=MIL not allowed yet - Must be in [PAR|GRA]"
    exit $TESTRESULT;;
    ## VPC BASTION 2 - LIM
    LIM) TESTRESULT=3
    echo "WARNING - Input VPC_REGION_NAME=LIM not supported yet - Must be in [PAR|GRA]"
    exit $TESTRESULT;;
    ## VPC BASTION 3 - GRA
    GRA) echo "DEPLOYING BASTION IN $VPC_REGION_NAME on mono zone"
    scripts/oscVPC-createBastion-gra.sh $VPC_ZONE
    echo "\!/ CHECK IF THE BASTION WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"
    TESTRESULT=0
    exit $TESTRESULT;;
    ## VPC BASTION 4 - PAR
    PAR) VPC_ZONE=eu-west-par-c
    echo "DEPLOYING BASTION IN $VPC_REGION_NAME on $VPC_ZONE zone"
    scripts/oscVPC-createBastion-par.sh $VPC_ZONE
    echo "\!/ CHECK IF THE BASTION WAS DEPLOYED IN $VPC_REGION_NAME SUCCESSFUL \!/"
    TESTRESULT=0
    exit $TESTRESULT;;
    ## ALL(*)
    *) TESTRESULT=2
    echo "ERROR - Input VPC_REGION_NAME not allowed - Must be in [MIL|LIM|PAR|GRA]"
    exit $TESTRESULT;;
esac
