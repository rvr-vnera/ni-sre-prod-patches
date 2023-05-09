#!/bin/bash

PSUTIL_FILE="_pslinux.py"
DD_PSUTIL_FILEPATH="/opt/datadog-agent/embedded/lib/python3.8/site-packages/psutil/"
TELEMETRY_SERVICE_PATH="/home/ubuntu/build-target/infra-base/telemetry"
BACKUP_DIR="${TELEMETRY_SERVICE_PATH}/psutil_backup/"

# Take Backup
echo "Taking Backup of pslinux file"
mkdir -p ${BACKUP_DIR}
sudo cp ${DD_PSUTIL_FILEPATH}/${PSUTIL_FILE} ${BACKUP_DIR}


#Copy new file to build-target
echo "Copying file to build target"
sudo cp /tmp/${PSUTIL_FILE} "$TELEMETRY_SERVICE_PATH/${PSUTIL_FILE}"
sudo chmod 750 "$TELEMETRY_SERVICE_PATH/${PSUTIL_FILE}"
sudo chown ubuntu:ubuntu "$TELEMETRY_SERVICE_PATH/${PSUTIL_FILE}"


# Copy new file to site packages
echo "Copying file to site packages"
sudo cp -fr "${TELEMETRY_SERVICE_PATH}/${PSUTIL_FILE}" "$DD_PSUTIL_FILEPATH"
sudo chmod 644 "${DD_PSUTIL_FILEPATH}/${PSUTIL_FILE}"
sudo chown dd-agent:dd-agent "${DD_PSUTIL_FILEPATH}/${PSUTIL_FILE}"


sudo systemctl restart datadog-agent 

sudo service datadog-agent status | grep Active
