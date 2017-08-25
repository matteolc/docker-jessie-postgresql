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

docker service create \
    --name master \
    --hostname master \
    --network=postgres \
    --restart-condition 'any' \
    --constraint 'node.labels.type == master' \
    --mount type=volume,source=master-volume,destination=/var/lib/postgresql \
    -p 5432:5432 \
    -e 'PG_TRUST_LOCALNET=true' \
    -e 'PG_PASSWORD=passw0rd' \
    -e 'DB_USER=dbuser' -e 'DB_PASS=dbuserpass' \
    -e 'DB_NAME=dbname1' -e 'DB_EXTENSION=citext,hstore,unaccent,pg_trgm' \
    -e 'REPLICATION_USER=repluser' -e 'REPLICATION_PASS=repluserpass' \
    voxbox/postgres \
    -c logging_collector=on \
    -c log_connections=on