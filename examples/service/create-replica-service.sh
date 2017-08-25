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
    --name replica \
    --hostname replica \
    --network=postgres \
    --restart-condition 'any' \
    --constraint 'node.labels.type != master' \
    --mount type=volume,source=replica-volume,destination=/var/lib/postgresql \
    -p 5433:5432 \
    -e 'PG_TRUST_LOCALNET=true' \
    -e 'REPLICATION_PORT=5432' \
    -e 'REPLICATION_HOST=master' \
    -e 'REPLICATION_MODE=slave' \
    -e 'REPLICATION_USER=repluser' \
    -e 'REPLICATION_PASS=repluserpass' \
    -e 'REPLICATION_SSLMODE=prefer' \
    voxbox/postgres 
    -c logging_collector=on \
    -c log_connections=on