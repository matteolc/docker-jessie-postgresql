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

echo "cleaning up ..."

STACK_NAME=db

MANAGER_IP=192.168.18.130
WORKER_IP=192.168.18.132

docker stack rm $STACK_NAME

docker swarm leave -f

ssh root@$WORKER_IP docker swarm leave

docker network prune -f

rm -Rf /home/postgresql/master
ssh root@$WORKER_IP rm -Rf /home/postgresql/replica
