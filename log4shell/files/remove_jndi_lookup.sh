#!/bin/bash

# This script removes JndiLookup class file from log4j-core-2.11.1 package 

LOG4J_FILE_PATH=/usr/share/elasticsearch/lib/log4j-core-2.11.1.jar
SCRATCH_DIR=/tmp/log4j-scratch
FILE_NAME=`basename $LOG4J_FILE_PATH`
LOG4J_BACKUP_DIR=/home/ubuntu/log4j_original

jar tf ${LOG4J_FILE_PATH} | grep -q "org/apache/logging/log4j/core/lookup/JndiLookup.class"
if [ $? -eq 0 ]; then
  rm -rf ${SCRATCH_DIR}
  mkdir -p ${SCRATCH_DIR}
  cd ${SCRATCH_DIR}
  jar xf ${LOG4J_FILE_PATH}
  rm org/apache/logging/log4j/core/lookup/JndiLookup.class 2> /dev/null
  jar cf ../${FILE_NAME} *
  sudo mkdir -p ${LOG4J_BACKUP_DIR}
  sudo cp ${LOG4J_FILE_PATH} ${LOG4J_BACKUP_DIR}
  sudo systemctl stop elasticsearch
  sudo cp ../${FILE_NAME} ${LOG4J_FILE_PATH}
  sudo systemctl start elasticsearch
  echo "JndiLookup class is removed successfully and elasticsearch is restarted"
else
  echo "JndiLookup class is already removed"
fi