#!/bin/bash

sudo rm -f /tmp/liagent.json
SERVICE_PATH="/home/ubuntu/build-target/infra-base"
CHEF_CONFIG_FILE="$SERVICE_PATH/infra-automation/upgrade_solo.rb"

RES=`cat <<EOF
{
    "name": "liagent",
    "description": "s",
    "chef_type": "role",
    "base": {
        "arkin_repo": "file:///var/cache/apt-cacher-ng/svc.ni.vmware.com/repo"
     },
    "run_list": [   "recipe[loginsight::config]",
                    "recipe[loginsight::service]"
    ]
}

EOF`
echo "$RES" > "/tmp/liagent.json"  
sudo chef-solo -c $CHEF_CONFIG_FILE -j /tmp/liagent.json
