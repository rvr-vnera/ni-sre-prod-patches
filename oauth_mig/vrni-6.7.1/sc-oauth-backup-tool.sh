#!/bin/bash

ENV=`cat /home/ubuntu/build-target/deployment/policies.properties | grep ^ENV= | cut -d '"' -f2`

java -Dpostgres.configuration=/home/ubuntu/build-target/saas-controller/postgres.configuration -Ddynamodb.configuration=/home/ubuntu/build-target/saas-controller/dynamodb.configuration -Dvrni.metrics.tags=env:$ENV -Dspring.config.location=/home/ubuntu/build-target/saas-controller/application.properties -cp /home/ubuntu/build-target/saas-controller/saas-tools-0.001-SNAPSHOT.jar com.vnera.saasinfra.saastools.scoauthBackup.SCOAuthRecordBackup
