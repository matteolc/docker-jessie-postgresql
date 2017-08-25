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
MASTER_CONTAINER=$(docker ps -qf name=master)
echo "---------------------------------------------------------------------"
echo "Waiting until Postresql is up"
echo "---------------------------------------------------------------------"
$DIR/wait-for-postgres.sh
echo "---------------------------------------------------------------------"
echo "Test users"
echo "---------------------------------------------------------------------"
docker exec -it $MASTER_CONTAINER sudo -u postgres psql -c "\dg"
echo "---------------------------------------------------------------------"
echo "Test databases"
echo "---------------------------------------------------------------------"
docker exec -it $MASTER_CONTAINER sudo -u postgres psql -c "\l"
echo "---------------------------------------------------------------------"
echo "Test extensions"
echo "---------------------------------------------------------------------"
docker exec -it $MASTER_CONTAINER sudo -u postgres psql -d dbname1 -c "\dx"
echo "---------------------------------------------------------------------"
echo "Create dummy data"
echo "---------------------------------------------------------------------"
docker exec -it $MASTER_CONTAINER sudo -u postgres psql -d dbname1 -c "CREATE TABLE guestbook (visitor_email text, vistor_id serial, date timestamp, message text);"
docker exec -it $MASTER_CONTAINER sudo -u postgres psql -d dbname1 -c "INSERT INTO guestbook (visitor_email, date, message) VALUES ( 'jim@gmail.com', current_date, 'This is a test.');"
docker exec -it $MASTER_CONTAINER sudo -u postgres psql -d dbname1 -c "SELECT * FROM guestbook;"