#######################################
#  compile the maven project
#######################################
FROM maven:3.5-jdk-8-alpine as build
ADD functions/pom.xml ./pom.xml
ADD functions/src ./src
RUN mvn clean compile test-compile package -DskipTests

#######################################
#  create a separated docker image to verify this utility
#######################################
#Set the base image :
FROM ubuntu:16.04

#File Author/Maintainer :
MAINTAINER Jacky<xxxxxx@gmail.com>

#Set workdir :
WORKDIR /opt/pivotal

#######################################
#  need to set the proper version (Action Required)
#######################################
ENV GEMFIREVERSION 9.5.1

COPY --from=build /target/functions-1.0.0.jar functions-1.0.0.jar

#install unzip 
RUN apt-get update
RUN apt-get install -y unzip zip

#Set the username to root :
USER root

#install openjdk
RUN apt-get update && \
	apt-get install -y openjdk-8-jdk && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;


#Add gemfire installation file
ADD gemfireproductlist /opt/pivotal/gemfireproductlist

#Install pivotal gemfire :
RUN unzip /opt/pivotal/gemfireproductlist/*zip 
#&& \
#    rm /opt/pivotal/gemfireproductlist/*.zip


#Setup environment variables :
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV GEMFIRE /opt/pivotal/pivotal-gemfire-$GEMFIREVERSION
ENV PATH $PATH:$JAVA_HOME/bin:$GEMFIRE/bin

#classpath setting
ENV CLASSPATH $GEMFIRE/lib/geode-dependencies.jar:$GEMFIRE/lib/gfsh-dependencies.jar:/opt/pivotal/workdir/classes:$CLASSPATH

#COPY the start scripts into container
COPY workdir /opt/pivotal/workdir

# Default ports:
# RMI/JMX 1099
# REST 8080
# PULSE 7070
# LOCATOR 10334
# CACHESERVER 40404
# UDP port: 53160
EXPOSE  8080 10334 40404 40405 1099 7070

# SET VOLUME directory
VOLUME ["/opt/pivotal/workdir"]