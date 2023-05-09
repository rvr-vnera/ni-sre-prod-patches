#!/bin/bash

BACKUP_DIR="/var/lib/ubuntu/backup/"
SCRATCH_DIR="/var/lib/tmp/scratchws"

#PLAT_SVCS="hbase-master hbase-regionserver hadoop-yarn-nodemanager hadoop-yarn-resourcemanager hadoop-hdfs-datanode hadoop-hdfs-journalnode hadoop-hdfs-namenode hadoop-hdfs-zkfc datadog-agent vipservice"
PLAT_SVCS="vipservice"

function restart_svc() {
  sudo systemctl stop "$1" >/dev/null 2>/dev/null
  sudo systemctl start "$1" >/dev/null 2>/dev/null
}

function restartPlatSvcs() {
  svcs=("$PLAT_SVCS")
  for asvc in ${svcs[@]}; do
    restart_svc "$asvc"
  done
}

function handle_file() {
  local filetohandle="$1"
  echo "Patching $filetohandle"
  if [[ ! -f $filetohandle ]]; then
    echo "$filetohandle not found"
    return
  fi
  apply_local "$filetohandle"
}

function backup_orig() {
  local filetobackup="$1"
  bkpath="$(dirname $filetobackup)"
  bkpfile="$(basename $filetobackup)"
  bkpathlocal="${bkpath#/}"
  newbkppath="${BACKUP_DIR}/${bkpathlocal}"
  mkdir -p "$newbkppath"
  cp "$filetobackup" "$newbkppath"/"$bkpfile".backup
}

function apply_local() {
  local filetohandle="$1"
  local filename="$(basename $filetohandle)"
  rm -rf "${SCRATCH_DIR}"
  mkdir -p "${SCRATCH_DIR}"
  cd "${SCRATCH_DIR}"
  jar -tf "$filetohandle" | grep -q JndiLookup
  if [[ $? != 0 ]]; then
    echo "No JndiLookup found in $filetohandle"
    return
  fi

  backup_orig "$filetohandle"

  jar -xf "$filetohandle"
  find . -type f | grep log4j | grep JndiLookup | xargs rm
  if [ -f "META-INF/MANIFEST.MF" ]; then
    jar -cfm ../${filename} META-INF/MANIFEST.MF *
  else
    jar -cf ../${filename} *
  fi
  cp ../"${filename}" "$filetohandle"
  cd
}

function fixVipService() {
  VIP_JAR_SCRATCH_DIR="/var/lib/tmp/vipscratch/jar-fixer"
  local filetohandle="$1"
  if [[ ! -f $filetohandle ]]; then
    echo "No VIP"
    return
  fi
  rm -rf "${VIP_JAR_SCRATCH_DIR}"
  mkdir -p "${VIP_JAR_SCRATCH_DIR}"
  cd "${VIP_JAR_SCRATCH_DIR}"
  echo "Checking $filetohandle"
  jar xf "${filetohandle}"
  fres="$(find `pwd` -name "*.jar" 2>/dev/null)"
  applied=0
  while read result; do
    jar -tf "$result"|grep -iq "log4j\/core\/lookup\/JndiLookup.class"
    if [ $? -eq 0 ]; then
      echo "Fixing $result"
      apply_local $result
      ANY_CHANGE=1
      applied=1
    fi
  done <<< "$fres"

  if [[ $applied == 1 ]]; then
    echo "Patched vipservice"
    backup_orig "$filetohandle"
    cd ${VIP_JAR_SCRATCH_DIR}
    jar -cfm0 ${filetohandle} META-INF/MANIFEST.MF *
    chown ubuntu:ubuntu ${filetohandle}
    cd
  fi
  rm -r ${VIP_JAR_SCRATCH_DIR}
}

mkdir -p $BACKUP_DIR

handle_file "/opt/hbck/hbase-hbck2.jar"
handle_file "/opt/datadog-agent/bin/agent/dist/jmx/jmxfetch.jar"
handle_file "/usr/lib/hadoop/lib/log4j-core-2.8.2.jar"
handle_file "/home/ubuntu/log4j_original/log4j-core-2.11.1.jar"
handle_file "/home/ubuntu/deploy/flink/lib/log4j-core-2.12.1.jar"
handle_file "/home/ubuntu/deploy/flink/bin/bash-java-utils.jar"
handle_file "/home/ubuntu/build-target/hbase/hbase-hbck2.jar"
handle_file "/usr/share/elasticsearch/lib/log4j-core-2.11.1.jar"

fixVipService "/home/ubuntu/build-target/vipservice/vipservice.jar"
restartPlatSvcs
