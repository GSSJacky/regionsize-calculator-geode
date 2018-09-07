#!/bin/bash

gfsh <<!
start locator --name=locator1 --port=10334 --initial-heap=256m --max-heap=256m
#start locator --name=locator1 --port=10334 --properties-file=config/locator.properties --initial-heap=256m --max-heap=256m

#configure pdx --portable-auto-serializable-classes=".*";

start server --name=server1 --server-port=40404 --locators=localhost[10334] --initial-heap=1g --max-heap=1g
start server --name=server2 --server-port=40405 --locators=localhost[10334] --initial-heap=1g --max-heap=1g

# deploy the functions
undeploy --jar=functions-1.0.0.jar
deploy --jar=../functions-1.0.0.jar

create region --name=exampleRegion --type=PARTITION_REDUNDANT
create region --name=customer --type=PARTITION

put --key='1' --value='Hello World1!!' --region=exampleRegion
put --key='2' --value='Hello World2!!' --region=exampleRegion
put --key='3' --value='Hello World3!!' --region=exampleRegion
put --key='4' --value='Hello World4!!' --region=exampleRegion
put --key='5' --value='Hello World5!!' --region=exampleRegion
put --key='6' --value='Hello World6!!' --region=exampleRegion
put --key='7' --value='Hello World7!!' --region=exampleRegion
put --key='8' --value='Hello World8!' --region=exampleRegion
put --key='9' --value='Hello World9!!' --region=exampleRegion
put --key='10' --value='Hello World10!!' --region=exampleRegion

list members;
list regions;
show metrics;

######  run the function service execution to calculate the region size ######
execute function --id=region-size-calculator --arguments="exampleRegion,10" --member=server1

exit;
!
