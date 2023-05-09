#!/bin/bash

#Script to install datadog agents
SERVICE_PATH=$1
FORCE=true
if [ ! -z "$2" ]; then
    FORCE=$2
fi
source "$SERVICE_PATH/props.sh"
source "$SERVICE_PATH/telemetry/configure-datadog-lib.sh" $SERVICE_PATH
source "$SERVICE_PATH/service-lib.sh"

CONFIGURE_PYTHON_SCRIPT="$SERVICE_PATH/telemetry/configure-datadog.py"

function stop_datadog_agent() {
        echo "Stopping datadog agent process"
        sudo /home/ubuntu/build-target/infra-base/telemetry/datadog-agent.sh stop
}

# Valid --type : "platform_jmx" | "proxy_jmx" | types starting with jmx_ such as "jmx_VIP", "jmx_DatabusGateway" etc. provided in install_* function below
function configure_datadog_agent_conf() {
        echo "creating data dog agent conf for $1"
        python3 $CONFIGURE_PYTHON_SCRIPT --type $1
        restart_datadog_agent
        echo "JMX configuration has completed for type $1"
}
function start_datadog_agent() {
        echo "starting datadog agent process"
        sudo /home/ubuntu/build-target/infra-base/telemetry/datadog-agent.sh start
        sleep 3
}
function restart_datadog_agent() {
        echo "restarting datadog agent process"
        sudo /home/ubuntu/build-target/infra-base/telemetry/datadog-agent.sh stop
        sudo /home/ubuntu/build-target/infra-base/telemetry/datadog-agent.sh start
        sleep 3
}
function install_vipservice_jmx_agent() {
        echo "############### SaasService JMX agent installation ###########################"
        sudo python3 /home/ubuntu/build-target/infra-base/telemetry/configure-datadog.py --type "jmx_VIP"
        if [ $FORCE == "true" ]; then
          restart_datadog_agent
        fi
        echo "VipService JMX agent configuration has completed"
}

function install_databus_gateway_jmx_agent() {
        echo "############### SaasService JMX agent installation ###########################"
        sudo python3  /home/ubuntu/build-target/infra-base/telemetry/configure-datadog.py --type "jmx_DatabusGateway"
        if [ $FORCE == "true" ]; then
          restart_datadog_agent
        fi
        echo "DatabusGateway JMX agent configuration has completed"
}

function install_batch_analytics_jmx_agent() {
        echo "############### BatchAnalytics Service JMX agent installation ###########################"
        sudo python3 /home/ubuntu/build-target/infra-base/telemetry/configure-datadog.py --type "jmx_Batch_Analytics"
        if [ $FORCE == "true" ]; then
          restart_datadog_agent
        fi
        echo "BatchAnalytics Service JMX agent configuration has completed"
}

function install_saasservice_jmx_agent() {
        echo "############### SaasService JMX agent installation ###########################"
        sudo python3 /home/ubuntu/build-target/infra-base/telemetry/configure-datadog.py --type "jmx_SaaS"
        if [ $FORCE == "true" ]; then
          restart_datadog_agent
        fi
        echo "SaasService JMX agent configuration has completed"
}

function install_restapi_jmx_agent() {
        echo "############### RestApi JMX agent installation ###########################"
        sudo python3 /home/ubuntu/build-target/infra-base/telemetry/configure-datadog.py --type "jmx_RestAPI"
        if [ $FORCE == "true" ]; then
          restart_datadog_agent
        fi
        echo "RestApi JMX agent configuration has completed"
}
function install_collector_jmx_agent() {
        echo "############### Collector JMX agent installation ###########################"
        sudo python3 /home/ubuntu/build-target/infra-base/telemetry/configure-datadog.py --type "jmx_Collector"
        if [ $FORCE == "true" ]; then
          restart_datadog_agent
        fi
        echo "Collector JMX agent configuration has completed"
}
function install_federation_jmx_agent() {
        echo "############### Federation JMX agent installation ###########################"
        sudo python3  /home/ubuntu/build-target/infra-base/telemetry/configure-datadog.py --type "jmx_Federation"
        if [ $FORCE == "true" ]; then
          restart_datadog_agent
        fi
        echo "Federation JMX agent configuration has completed"
}
function install_ipfix_jmx_agent() {
        echo "############### IpFix JMX agent installation ###########################"
        sudo python3 /home/ubuntu/build-target/infra-base/telemetry/configure-datadog.py --type "jmx_IPFix"
        if [ $FORCE == "true" ]; then
          restart_datadog_agent
        fi
        echo "IpFix JMX agent configuration has completed"
}

function install_tsdb_jmx_agent() {
        echo "############### TSDB JMX agent installation ###########################"
        sudo python3 /home/ubuntu/build-target/infra-base/telemetry/configure-datadog.py --type "jmx_tsdb"
        if [ $FORCE == "true" ]; then
          restart_datadog_agent
        fi
        echo "TSDB JMX agent configuration has completed"
}

function install_launcher_jmx_agent() {
        echo "############### Launcher JMX agent installation ###########################"
        sudo python3 /home/ubuntu/build-target/infra-base/telemetry/configure-datadog.py --type "jmx_Launcher"
        if [ $FORCE == "true" ]; then
          restart_datadog_agent
        fi
        echo "Launcher JMX agent configuration has completed"
}

function main_configure() {
  datadog_hostname=`sudo grep -E "^hostname:" $DATADOG_CONF_FILE` || true
  ip_address=`/sbin/ifconfig eth0 | grep 'inet' | cut -d: -f2 | awk '{print $2}'`
  host_name=`hostname`
  #update datadog url
  # each time check the policy and update the dd url. Only update of tags and hostname will remain option thing
  enable_reporters=`cat /home/ubuntu/build-target/deployment/policies.properties | grep ^ENABLE_REPORTERS= | cut -d '"' -f2`
  if [ "$enable_reporters" = "" ] || [ "$enable_reporters" = "no" ] || [ "$enable_reporters" = "NO" ]; then
      echo "ENABLE_REPORTERS is set to no. Setting dummy url for dd_url in datadog.conf."
      sed -i 's,dd_url:.*,dd_url: '"$METRIC_API_PROXY_URL_DUMMY"',g' $DATADOG_CONF_FILE
  else
      sed -i 's,dd_url:.*,dd_url: '"$METRIC_API_PROXY_URL"',g' $DATADOG_CONF_FILE
  fi

  if [[ "$FORCE" != "true" ]] && [[ "$datadog_hostname" =~ .*"$host_name.$ip_address".* ]] && grep -q ".*did:$DEPLOYMENT_ID.*" "$DATADOG_CONF_FILE" && grep -q ".*iid:$DEPLOYMENT_INFO.*" "$DATADOG_CONF_FILE"; then
    echo "Datadog is already configured. Only updated dd_url. Skipping other configuration change..."
    exit 0
  fi

  echo "##############Datadog agent installation####################"
  env=""
  role=""
  setup=""

  if [ -f "$POLICIES_FILE" ];then
          env=`cat $POLICIES_FILE | grep ^ENV= | cut -d '"' -f2`
          role=`cat $POLICIES_FILE | grep ^ROLE= | cut -d '"' -f2`
          setup=`cat $POLICIES_FILE | grep ^SETUP_NAME= | cut -d '"' -f2`
  fi

  if [ "$env" == "" ];then
          env="VRNI-NEW-DEV"
  fi

  if [ "$role" == "" ];then
          role=$SKU_INFO
  fi

  #CONVERT ALL CHARACTERS to upper case
  role="${role^^}"
  if [ "$setup" == "" ];then
          setup="UNKNOWN"
  fi

  if [ $FORCE == "true" ]; then
      stop_datadog_agent
  fi

  get_ddurl $role $env
  ddurl=$return_value

  get_hostname $role $env
  hostname=$return_value

  get_tags $env $role $setup
  tag=$return_value

  echo $ddurl
  echo $hostname
  echo $tag
  python3 $CONFIGURE_PYTHON_SCRIPT --type "main" \
                                   --file "$DATADOG_CONF_FILE" \
                                   --template "$DATADOG_CONF_TEMPLATE_FILE" \
                                   --hostname "$hostname" \
                                   --ddurl "$ddurl" \
                                   --skipsslvalidation "true" \
                                   --logtosyslog false \
                                   --tags "$tag"
  chown dd-agent:dd-agent $DATADOG_CONF_FILE
  chmod 775 $DATADOG_CONF_FILE

  echo "############Datadog agent installation has completed##################"

  # Change ntp configuration of datadog to use local servers instead of external random NTP servers
  use_local_ntp
  if [ "$role" = "PLATFORM" ]; then
          install_hdfs_agent
          install_yarn_agent
          install_elastic_search_agent
          install_kafka_agent
          install_kafka_consumer_agent
          install_nginx_agent
          install_zookeeper_agent
          install_hbase_agent
          install_directory_agent
          python3 $CONFIGURE_PYTHON_SCRIPT --type "platform_jmx"
          install_foundationdb_agent_check
          install_network_latency_agent_check
          install_agent_check "elasticsearch"
          install_agent_check "native_memory_tracking"
          set_default_agent_collection_interval
  elif [ "$role" = "PROXY" ]; then
          install_nginx_agent
          python3 $CONFIGURE_PYTHON_SCRIPT --type "proxy_jmx"
          install_foundationdb_agent_check
          install_network_latency_agent_check
          install_agent_check "native_memory_tracking"
          set_default_agent_collection_interval
  elif [ "$role" = "SAAS-CONTROLLER" ]; then
          install_nginx_agent
          install_foundationdb_agent_check
          set_default_agent_collection_interval
  elif [ "$role" = "GATEWAY" ]; then
          install_nginx_agent
          set_default_agent_collection_interval
  elif [ "$role" = "ELASTICSEARCH" ]; then
          install_elastic_search_agent
          install_agent_check "elasticsearch"
          set_default_agent_collection_interval
  fi
  install_process_check $role
  update_process_permissions
  if [ $FORCE == "true" ]; then
      start_datadog_agent
  fi
}

