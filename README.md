# Region Size Calculator

## Prerequisite

1.Gemfire 9.x

2.Use docker to compile the maven project and gemfire docker image to connect with gemfire cluster or test in gemfire docker container. Tested with Docker Community Edition for Mac 18.06.0-ce-mac69 (26398)

## Usage

This Function Execution Service： `region-size-calculator` Usage

**Input:**

- *Required argument*:  the name of the region
- *Optional argument*: the number of samples to take. If you have a region with 1 billion entries, you may deem it unnecessary to go through each entry and calculate its size. For this reason, this argument will limit the number of entries to sample and the total size will be projected from the results * the number of entries in the region.
- Function execution arguments in gfsh are **comma-delimited strings**


**Output:**

Output items are as the below, the size unit is **Byte**.
- *Deserialized values size* 
- *Serialized values size*
- *Keys size*
- *Region type*
- *Entries*

*For example:*
```
gfsh>execute function --id=region-size-calculator --arguments="exampleRegion,10" --member=server1
Execution summary

         Member ID/Name          | Function Execution Result
-------------------------------- | ----------------------------------------------------------------------------------------------------------------
172.17.0.2(server1:162)<v1>:1025 | [{Deserialized values size=720, Serialized values size=170, Keys size=480, Region type=Partitioned, Entries=10}]
```

## Considerations

The cost of calculating object sizes in a high-speed data grid is too expensive to perform on each entry. This Region Size Calculator calculates the sizes based on the following a few considerations.

1.Understanding GemFire Serialization

GemFire stores data in serialized form. It will store the object in deserialized form in some circumstances temporarily. This deserialized object will later be garbage collected. Therefore, the actual region size will flux depending on your operations.
If you store your objects using PDX and do queries with “Select *”, GemFire will store the object in deserialized form until the next GC. If your queries use fieldnames, such as “Select lastName, firstName”, GemFire will maintain the object in serialized form.
Function execution will also affect PDX deserialization. If your function casts a PDX object to it’s domain object, the object will be stored in deserialized form on that node and that node only temporarily. 

2.The Region Size Calculator will return both the size of the deserialized storage and serialized storage. You can estimate the real size of the region based on your use. If you do not use “Select *” and do not cast PDX objects to the Domain object in functions, your region size will be the sum of the keys and the deserialized values.


## Installation

**_Step1:_** 

Download this project to a local env and then unzip it as a folder such as [geode-region-size-calculator].

**_Step2:_**

Download gemfire product zip file from pivotal network such as pivotal-gemfire-9.5.1.zip. Put it into [geode-region-size-calculator]/gemfireproductlist foder.

**_Step3:_** 

Modify the Dockerfile according to your gemfire product version:
```
ENV GEMFIREVERSION 9.5.1
```

**_Step4:_** 

Open a terminal and move to this folder, then run the below docker command to build a docker image(Including two major actions: compile the maven project and setup gemfire9 env):
```
docker build . -t regionsizecalculator9:0.1
```

**_Step5:_** 

Login into the gemfire9 env contain and verify the function execution service.
```
docker run -it regionsizecalculator9:0.1 bash
```

```
JackynoMacBook-puro:geode-region-size-calculator jackyxu$ docker run -it regionsizecalculator9:0.1 bash
root@a1e64f5782ce:/opt/pivotal# ls
functions-1.0.0.jar  gemfireproductlist  pivotal-gemfire-9.5.1  workdir
root@a1e64f5782ce:/opt/pivotal# ls -l
total 24
-rw-r--r-- 1 root root 10059 Sep  7 03:32 functions-1.0.0.jar
drwxr-xr-x 2 root root  4096 Sep  7 03:33 gemfireproductlist
drwxr-xr-x 9 root root  4096 Jun 19 17:19 pivotal-gemfire-9.5.1
drwxr-xr-x 2 root root  4096 Sep  7 03:34 workdir
root@a1e64f5782ce:/opt/pivotal# cd workdir
root@a1e64f5782ce:/opt/pivotal/workdir# ls
start2servers.sh  startall.sh
root@a1e64f5782ce:/opt/pivotal/workdir# ./startall.sh 
    _________________________     __
   / _____/ ______/ ______/ /____/ /
  / /  __/ /___  /_____  / _____  / 
 / /__/ / ____/  _____/ / /    / /  
/______/_/      /______/_/    /_/    9.5.1

Monitor and Manage Pivotal GemFire
gfsh>start locator --name=locator1 --port=10334 --initial-heap=256m --max-heap=256m
Starting a Geode Locator in /opt/pivotal/workdir/locator1...
.....
Locator in /opt/pivotal/workdir/locator1 on a1e64f5782ce[10334] as locator1 is currently online.
Process ID: 64
Uptime: 5 seconds
Geode Version: 9.5.1
Java Version: 1.8.0_181
Log File: /opt/pivotal/workdir/locator1/locator1.log
JVM Arguments: -Dgemfire.enable-cluster-configuration=true -Dgemfire.load-cluster-configuration-from-dir=false -Xms256m -Xmx256m -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=60 -Dgemfire.launcher.registerSignalHandlers=true -Djava.awt.headless=true -Dsun.rmi.dgc.server.gcInterval=9223372036854775806
Class-Path: /opt/pivotal/pivotal-gemfire-9.5.1/lib/geode-core-9.5.1.jar:/opt/pivotal/pivotal-gemfire-9.5.1/lib/geode-dependencies.jar:/opt/pivotal/pivotal-gemfire-9.5.1/extensions/gemfire-greenplum-3.2.0.jar

Successfully connected to: JMX Manager [host=a1e64f5782ce, port=1099]

Cluster configuration service is up and running.

gfsh>
gfsh>#configure pdx --portable-auto-serializable-classes=".*";
gfsh>
gfsh>start server --name=server1 --locators=localhost[10334] --initial-heap=1g --max-heap=1g
Starting a Geode Server in /opt/pivotal/workdir/server1...
....
Server in /opt/pivotal/workdir/server1 on a1e64f5782ce[40404] as server1 is currently online.
Process ID: 162
Uptime: 4 seconds
Geode Version: 9.5.1
Java Version: 1.8.0_181
Log File: /opt/pivotal/workdir/server1/server1.log
JVM Arguments: -Dgemfire.locators=localhost[10334] -Dgemfire.start-dev-rest-api=false -Dgemfire.use-cluster-configuration=true -Xms1g -Xmx1g -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=60 -Dgemfire.launcher.registerSignalHandlers=true -Djava.awt.headless=true -Dsun.rmi.dgc.server.gcInterval=9223372036854775806
Class-Path: /opt/pivotal/pivotal-gemfire-9.5.1/lib/geode-core-9.5.1.jar:/opt/pivotal/pivotal-gemfire-9.5.1/lib/geode-dependencies.jar:/opt/pivotal/pivotal-gemfire-9.5.1/extensions/gemfire-greenplum-3.2.0.jar

gfsh>
gfsh># deploy the functions
gfsh>undeploy --jar=functions-1.0.0.jar
Member  |   Un-Deployed JAR   | Un-Deployed From JAR Location
------- | ------------------- | -----------------------------
server1 | functions-1.0.0.jar | JAR not deployed

gfsh>deploy --jar=../functions-1.0.0.jar

Deploying files: functions-1.0.0.jar
Total file size is: 0.01MB

Continue?  (Y/n): 
Member  |    Deployed JAR     | Deployed JAR Location
------- | ------------------- | ---------------------------------------------------
server1 | functions-1.0.0.jar | /opt/pivotal/workdir/server1/functions-1.0.0.v1.jar

gfsh>create region --name=exampleRegion --type=PARTITION
Member  | Status
------- | --------------------------------------------
server1 | Region "/exampleRegion" created on "server1"

gfsh>create region --name=customer --type=PARTITION
Member  | Status
------- | ---------------------------------------
server1 | Region "/customer" created on "server1"

gfsh>
gfsh>
gfsh>put --key='1' --value='Hello World1!!' --region=exampleRegion
Result      : true
Key Class   : java.lang.String
Key         : 1
Value Class : java.lang.String
Old Value   : <NULL>


gfsh>put --key='2' --value='Hello World2!!' --region=exampleRegion
Result      : true
Key Class   : java.lang.String
Key         : 2
Value Class : java.lang.String
Old Value   : <NULL>


gfsh>put --key='3' --value='Hello World3!!' --region=exampleRegion
Result      : true
Key Class   : java.lang.String
Key         : 3
Value Class : java.lang.String
Old Value   : <NULL>


gfsh>put --key='4' --value='Hello World4!!' --region=exampleRegion
Result      : true
Key Class   : java.lang.String
Key         : 4
Value Class : java.lang.String
Old Value   : <NULL>


gfsh>put --key='5' --value='Hello World5!!' --region=exampleRegion
Result      : true
Key Class   : java.lang.String
Key         : 5
Value Class : java.lang.String
Old Value   : <NULL>


gfsh>put --key='6' --value='Hello World6!!' --region=exampleRegion
Result      : true
Key Class   : java.lang.String
Key         : 6
Value Class : java.lang.String
Old Value   : <NULL>


gfsh>put --key='7' --value='Hello World7!!' --region=exampleRegion
Result      : true
Key Class   : java.lang.String
Key         : 7
Value Class : java.lang.String
Old Value   : <NULL>


gfsh>put --key='8' --value='Hello World8!' --region=exampleRegion
Result      : true
Key Class   : java.lang.String
Key         : 8
Value Class : java.lang.String
Old Value   : <NULL>


gfsh>put --key='9' --value='Hello World9!!' --region=exampleRegion
Result      : true
Key Class   : java.lang.String
Key         : 9
Value Class : java.lang.String
Old Value   : <NULL>


gfsh>put --key='10' --value='Hello World10!!' --region=exampleRegion
Result      : true
Key Class   : java.lang.String
Key         : 10
Value Class : java.lang.String
Old Value   : <NULL>


gfsh>
gfsh>list members;
  Name   | Id
-------- | ----------------------------------------------------------
locator1 | 172.17.0.2(locator1:64:locator)<ec><v0>:1024 [Coordinator]
server1  | 172.17.0.2(server1:162)<v1>:1025

gfsh>list regions;
List of regions
---------------
customer
exampleRegion

gfsh>show metrics;

Cluster-wide Metrics

Category  |        Metric         | Value
--------- | --------------------- | -----
cluster   | totalHeapSize         | 1254
cache     | totalRegionEntryCount | 0
          | totalRegionCount      | 2
          | totalMissCount        | 1
          | totalHitCount         | 4
diskstore | totalDiskUsage        | 0
          | diskReadsRate         | 0.0
          | diskWritesRate        | 647.0
          | flushTimeAvgLatency   | 0
          | totalBackupInProgress | 0
query     | activeCQCount         | 0
          | queryRequestRate      | 0.0

gfsh>
gfsh>######  run the function service execution to calculate the region size ######
gfsh>execute function --id=region-size-calculator --arguments="exampleRegion,10" --member=server1
Execution summary

         Member ID/Name          | Function Execution Result
-------------------------------- | ----------------------------------------------------------------------------------------------------------------
172.17.0.2(server1:162)<v1>:1025 | [{Deserialized values size=720, Serialized values size=170, Keys size=480, Region type=Partitioned, Entries=10}]

gfsh>
```



You can also login into container and run this container as gfsh, connect with your own remote gemfire cluster and deploy the function execution service jar.
```
docker run -it regionsizecalculator9:0.1 gfsh
```

```
JackynoMacBook-puro:geode-region-size-calculator jackyxu$ docker run -it regionsizecalculator9:0.1 gfsh
    _________________________     __
   / _____/ ______/ ______/ /____/ /
  / /  __/ /___  /_____  / _____  / 
 / /__/ / ____/  _____/ / /    / /  
/______/_/      /______/_/    /_/    9.5.1

Monitor and Manage Pivotal GemFire
gfsh>connect  --locator=172.16.196.210[7900]
Connecting to Locator at [host=172.16.196.210, port=7900] ..
Connecting to Manager at [host=172.16.196.210, port=1099] ..
Successfully connected to: [host=172.16.196.210, port=1099]

Cluster-1 gfsh>list members
 Name   | Id
------- | ---------------------------------------------------------------
locator | 172.16.196.210(locator:6059:locator)<ec><v0>:1024 [Coordinator]
server1 | 172.16.196.210(server1:6205)<v1>:1025
server2 | 172.16.196.210(server2:6518)<v2>:1026

Cluster-1 gfsh>list regions
List of regions
---------------
customer
exampleRegion
rewards

Cluster-1 gfsh>list deployed
No JAR Files Found

Cluster-1 gfsh>show metrics

Cluster-wide Metrics

Category  |        Metric         | Value
--------- | --------------------- | -----
cluster   | totalHeapSize         | 2010
cache     | totalRegionEntryCount | 12011
          | totalRegionCount      | 3
          | totalMissCount        | 0
          | totalHitCount         | 4
diskstore | totalDiskUsage        | 0
          | diskReadsRate         | 0.0
          | diskWritesRate        | 0.0
          | flushTimeAvgLatency   | 0
          | totalBackupInProgress | 0
query     | activeCQCount         | 0
          | queryRequestRate      | 0.0

Cluster-1 gfsh>deploy --jar=functions-1.0.0.jar

Deploying files: functions-1.0.0.jar
Total file size is: 0.01MB

Continue?  (Y/n): Y
Member  |    Deployed JAR     | Deployed JAR Location
------- | ------------------- | -----------------------------------------------------------
server1 | functions-1.0.0.jar | /home/gpadmin/apps/gemfire95/server1/functions-1.0.0.v1.jar
server2 | functions-1.0.0.jar | /home/gpadmin/apps/gemfire95/server2/functions-1.0.0.v1.jar

Cluster-1 gfsh>execute function --id=region-size-calculator --arguments="customer,10" --member=server1
Execution summary

           Member ID/Name             | Function Execution Result
------------------------------------- | ----------------------------------------------------------------------------------------------
172.16.196.210(server1:6205)<v1>:1025 | [{Serialized values size=768,000, Keys size=768,000, Region type=Partitioned, Entries=12,000}]

Cluster-1 gfsh>execute function --id=region-size-calculator --arguments="customer,12000" --member=server1
Execution summary

           Member ID/Name             | Function Execution Result
------------------------------------- | ----------------------------------------------------------------------------------------------
172.16.196.210(server1:6205)<v1>:1025 | [{Serialized values size=756,000, Keys size=756,000, Region type=Partitioned, Entries=12,000}]
```



## Reference

1.Gemfire8.2.x based gemfire region size calculator utility.

https://github.com/Pivotal-Data-Engineering/gemfire-region-size-calculator

2.Gemfire6.x based gemfire region calculator utility.

https://communities.vmware.com/docs/DOC-20695
