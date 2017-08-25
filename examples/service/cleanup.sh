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

MANAGER_IP=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
WORKER_IP=192.168.18.132
MANAGER_DN=$(hostname)
WORKER_DN=$(ssh root@$WORKER_IP hostname)

docker service rm master
docker service rm replica

docker swarm leave -f
ssh root@$WORKER_IP docker swarm leave

docker network prune -f
ssh root@$WORKER_IP docker network prune -f

docker volume prune -f
ssh root@$WORKER_IP docker volume prune -f