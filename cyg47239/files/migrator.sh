#!/bin/bash

set -x

cp /tmp/tools-0.001-SNAPSHOT.jar  ~/build-target/common-utils/tools-metrics-0.001-SNAPSHOT.jar
cp ~/build-target/common-utils/run-debugger.sh  ~/build-target/common-utils/run-metrics-debugger.sh
sed -e 's/-0.001-SNAPSHOT.jar/-metrics-0.001-SNAPSHOT.jar/g' -i ~/build-target/common-utils/run-metrics-debugger.sh
hd=`cat /home/ubuntu/build-target/deployment/patch.txt | tail -1 | cut -d '[' -f 2 | cut -d ']' -f 1`
eds=`date --date="$hd" +"%s"`
edm=$(($eds*1000))
echo "End Time: $edm"
cd ~/build-target/common-utils/
chmod +x ./run-metrics-debugger.sh
nohup echo "migrate_metrics -et $edm" | ./run-metrics-debugger.sh
