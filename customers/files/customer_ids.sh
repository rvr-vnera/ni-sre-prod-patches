#!/bin/bash
cids=`echo "customerId" | /home/ubuntu/build-target/common-utils/run-debugger.sh | grep Customer | cut -d '=' -f2`
cidlist=`echo $cids | sed -e 's/,/ /g'`
podnumber=$(cat /home/ubuntu/build-target/deployment/policies.properties | grep "SETUP_NAME" | cut -d'=' -f2 | tr -d '"')
file=/tmp/${podnumber}_customers.json

echo "{" > $file
echo "\"podNumber\": \"$podnumber\"," >> $file
echo "\"customerIds\" : \"$cids\"" >> $file
echo "}" >> $file
