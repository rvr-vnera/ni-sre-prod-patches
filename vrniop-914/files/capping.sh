#!/bin/bash

did=`cat /home/ubuntu/build-target/deployment/deployment.id`
podname=`cat /home/ubuntu/build-target/deployment/policies.properties | grep SETUP_NAME`
echo $podname
echo "DID=$did"

cids=`echo "customerId" | /home/ubuntu/build-target/common-utils/run-debugger.sh | grep Customer | cut -d '=' -f2`
cidlist=`echo $cids | sed -e 's/,/ /g'`
for c in $cidlist; do
    if [[ $c == 1 ]]; then
        continue
    fi
    echo "CID: $c"
    cs=`echo get_policy -cid $c -key cappingScheme -ns features | /home/ubuntu/build-target/common-utils/run-debugger.sh | grep cappingScheme | grep ":" | cut -d ':' -f 2 | tr -d '"' | tr -d ' '`
    if [[ $cs == "resourceLevel" ]]; then
        echo get_policy -cid $c -ns billing | /home/ubuntu/build-target/common-utils/run-debugger.sh | grep "\""
    fi
done
