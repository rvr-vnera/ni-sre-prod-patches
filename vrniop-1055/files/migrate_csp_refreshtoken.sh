#!/bin/bash
cids=`echo "customerId" | /home/ubuntu/build-target/common-utils/run-debugger.sh | grep Customer | cut -d '=' -f2`
cidlist=`echo $cids | sed -e 's/,/ /g'`
for customer in $cidlist;
do
    if [[ $customer == 1 ]]; then
        continue
    fi
    echo "Running csp refresh token migration for customer $customer"
    java -Dplatform_shared_keypair_pub=/home/ubuntu/build-target/deployment/keys/shared.crt -cp tools-0.001-SNAPSHOT.jar com.vnera.tools.commands.platform.vmc.MigrateCSPRefreshToken -cid $customer
    echo "Completed execution for customer $customer"
    sleep 3s
done