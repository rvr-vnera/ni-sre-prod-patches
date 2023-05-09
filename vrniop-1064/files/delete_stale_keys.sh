#!/bin/bash

cids=`echo "customerId" | /home/ubuntu/build-target/common-utils/run-debugger.sh  | grep "Customer Ids=" | cut -d','  --output-delimiter ' ' -f2- `
#for cid in $cids; do echo "key_val_tool -m del -cid $cid -key \"$cid:ProxyKey\"";  done >> delete_stale_keys_commands
#/home/ubuntu/build-target/common-utils/run-debugger.sh  -f delete_stale_keys_commands

for cid in $cids; do echo "key_val_tool -m get -cid $cid -key \"$cid:ProxyKey\"";  done >> get_stale_keys_commands
/home/ubuntu/build-target/common-utils/run-debugger.sh  -f get_stale_keys_commands
