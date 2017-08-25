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
MANAGER_IP=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
WORKER_IP=192.168.18.132
MANAGER_DN=$(hostname)
WORKER_DN=$(ssh root@$WORKER_IP hostname)
echo "---------------------------------------------------------------------"
echo "Cleaning up"
echo "---------------------------------------------------------------------"
$DIR/cleanup.sh
echo "---------------------------------------------------------------------"
echo "Initializing Swarm"
echo "---------------------------------------------------------------------"
docker swarm init
echo "---------------------------------------------------------------------"
echo "Joining a worker to the swarm"
echo "---------------------------------------------------------------------"
TOKEN=$(docker swarm join-token worker -q)
ssh root@$WORKER_IP docker swarm join --token $TOKEN  $MANAGER_IP:2377
echo "---------------------------------------------------------------------"
echo "Nodes in the swarm:"
echo "---------------------------------------------------------------------"
docker node ls
echo "---------------------------------------------------------------------"
echo "Adding master/replica labels to the nodes"
echo "---------------------------------------------------------------------"
docker node update \
  --label-add type=master \
  $MANAGER_DN
docker node update \
  --label-add type=replica \
  $WORKER_DN
echo "---------------------------------------------------------------------"
echo "Creating an overlay network"
echo "---------------------------------------------------------------------"
docker network create \
  --driver overlay \
  --attachable \
  postgres
echo "---------------------------------------------------------------------"
echo "Creating services"
echo "---------------------------------------------------------------------"
$DIR/create-master-service.sh
$DIR/create-replica-service.sh
echo "---------------------------------------------------------------------"
echo "Services:"
echo "---------------------------------------------------------------------"
docker service ls
echo "---------------------------------------------------------------------"
echo "Running test..."
echo "---------------------------------------------------------------------"
../test/run.sh

