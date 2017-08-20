#!/bin/bash

# Copyright 2017 Voxbox.io
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$DIR/cleanup.sh

echo "starting master container..."

MASTER_CONTAINER_NAME=master

docker run -itd \
    --privileged \
    --name $MASTER_CONTAINER_NAME \
    --env 'PG_TRUST_LOCALNET=true' \
    --env 'PG_PASSWORD=passw0rd' \
    --env 'DB_USER=dbuser' --env 'DB_PASS=dbuserpass' \
    --env 'DB_NAME=dbname1,dbname2' --env 'DB_EXTENSION=citext,hstore,unaccent,pg_trgm' \
    --env 'REPLICATION_USER=repluser' --env 'REPLICATION_PASS=repluserpass' \
    --publish 5432:5432 \
    --volume $MASTER_CONTAINER_NAME-volume:/var/lib/postgresql \
    voxbox/postgres \
    -c checkpoint_completion_target=0.9 \
    -c effective_cache_size=512MB \
    -c lc_messages='C' \
    -c logging_collector=on \
    -c log_connections=on \
    -c maintenance_work_mem=2GB \
    -c max_connections=9998 \
    -c max_wal_size=4GB \
    -c min_wal_size=2GB \
    -c shared_buffers=256MB \
    -c wal_buffers=16M \
    -c work_mem=4MB

echo "starting replica container..."
sleep 20

CONTAINER_NAME=replica

docker run -itd \
    --privileged \
    --name $CONTAINER_NAME \
    --env 'REPLICATION_MODE=slave' --env 'REPLICATION_SSLMODE=prefer' \
    --env 'REPLICATION_HOST=master' --env 'REPLICATION_PORT=5432'  \
    --env 'REPLICATION_USER=repluser' --env 'REPLICATION_PASS=repluserpass' \
    --link $MASTER_CONTAINER_NAME:master \
    --volume $MASTER_CONTAINER_NAME-volume:/var/lib/postgresql \
    voxbox/postgres \
    -c checkpoint_completion_target=0.9 \
    -c effective_cache_size=512MB \
    -c lc_messages='C' \
    -c logging_collector=on \
    -c log_connections=on \
    -c maintenance_work_mem=2GB \
    -c max_connections=9998 \
    -c max_wal_size=4GB \
    -c min_wal_size=2GB \
    -c shared_buffers=256MB \
    -c wal_buffers=16M \
    -c work_mem=4MB