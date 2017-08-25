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


#    -c checkpoint_completion_target=0.9 \
#    -c effective_cache_size=512MB \
#    -c lc_messages='C' \
#    -c maintenance_work_mem=2GB \
#    -c max_connections=128 \
#    -c max_wal_size=4GB \
#    -c min_wal_size=2GB \
#    -c shared_buffers=512MB \
#    -c wal_buffers=16MB \
#    -c work_mem=4MB

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "---------------------------------------------------------------------"
echo "Setting host kernel limits"
echo "---------------------------------------------------------------------"
$DIR/set-host-kernel-limits.sh
ssh root@$WORKER_IP "bash -s" < $DIR/set-host-kernel-limits.sh
echo "---------------------------------------------------------------------"
echo "Verify host kernel limits"
echo "---------------------------------------------------------------------"
ipcs -l
ssh root@$WORKER_IP ipcs -l