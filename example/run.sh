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

STACK_NAME=db

MANAGER_IP=192.168.18.130
MANAGER_DN=daddy-monkey
WORKER_IP=192.168.18.132
WORKER_DN=sun-bird

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Cleaning up"
$DIR/cleanup.sh

echo "Setting host kernel limits"
$DIR/set_host_kernel_limits.sh
# RUN THIS IN EVERY HOST

echo "Initializing Swarm"
docker swarm init

echo "Joining a worker to the swarm"
TOKEN=$(docker swarm join-token worker -q)
ssh root@$WORKER_IP docker swarm join --token $TOKEN  $MANAGER_IP:2377

echo "Nodes in the swarm:"
docker node ls

echo "Adding master/replica labels to the nodes"
docker node update --label-add type=master $MANAGER_DN
docker node update --label-add type=replica $WORKER_DN

echo "Deploying the stack to the swarm"
docker stack deploy -c docker-compose.yml $STACK_NAME

echo "Stack status:"
docker stack ls
docker stack ps $STACK_NAME

echo "Waiting until all containers are running"
sleep 20
MASTER_CONTAINER=$(docker ps -qf name=master)

echo "Verify user have been created"
docker exec -it $MASTER_CONTAINER sudo -u postgres psql -c "\dg"

echo "Verify all databases have been created"
docker exec -it $MASTER_CONTAINER sudo -u postgres psql -c "\l"
echo "Verify all extensions have been installed"
docker exec -it $MASTER_CONTAINER sudo -u postgres psql -c "\c dbname1;"

echo "Let's create some dummy data"
docker exec -it $MASTER_CONTAINER sudo -u postgres psql -d dbname1 -c "CREATE TABLE guestbook (visitor_email text, vistor_id serial, date timestamp, message text);"
docker exec -it $MASTER_CONTAINER sudo -u postgres psql -d dbname1 -c "INSERT INTO guestbook (visitor_email, date, message) VALUES ( 'jim@gmail.com', current_date, 'This is a test.');"
docker exec -it $MASTER_CONTAINER sudo -u postgres psql -d dbname1 -c "SELECT * FROM guestbook;"

echo "Let's verify that dummy data has been replicated"
ssh root@$WORKER_IP 'export WORKER_CONTAINER=$(docker ps -qf name=replica); docker exec -i $WORKER_CONTAINER sudo -u postgres psql -d dbname1 -c "SELECT * FROM guestbook;"'

echo "Let's create some more dummy data"
docker exec -it $MASTER_CONTAINER sudo -u postgres psql -d dbname1 -c "INSERT INTO guestbook (visitor_email, date, message) VALUES ( 'joe@gmail.com', current_date, 'This is another test.');"
docker exec -it $MASTER_CONTAINER sudo -u postgres psql -d dbname1 -c "SELECT * FROM guestbook;"

echo "Let's verify that dummy data has been replicated"
ssh root@$WORKER_IP 'export WORKER_CONTAINER=$(docker ps -qf name=replica); docker exec -i $WORKER_CONTAINER sudo -u postgres psql -d dbname1 -c "SELECT * FROM guestbook;"'

