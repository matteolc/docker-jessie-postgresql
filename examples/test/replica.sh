#!/bin/bash

# Copyright 2017 Voxbxo.io
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
WORKER_IP=192.168.18.132
echo "---------------------------------------------------------------------"
echo "Waiting until Postresql is up"
echo "---------------------------------------------------------------------"
$DIR/wait-for-postgres.sh $WORKER_IP 5433
echo "---------------------------------------------------------------------"
echo "Verify dummy data replica"
echo "---------------------------------------------------------------------"
ssh root@$WORKER_IP 'export WORKER_CONTAINER=$(docker ps -qf name=replica); docker exec -i $WORKER_CONTAINER sudo -u postgres psql -d dbname1 -c "SELECT * FROM guestbook;"'
