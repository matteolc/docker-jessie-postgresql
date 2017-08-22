#!/bin/bash

# Run the ipcs -l command to list the current kernel parameter settings.
#
# -> ipcs -l
# 
#    ------ Messages: Limits --------
#    max queues system wide = 1024               // MSGMNI. 
#    max size of message (bytes) = 65536         // MSGMAX. Maximum size of a message.
#    default max size of queue (bytes) = 65536   // MSGMNB. Default maximum size of a queue.
# 
#    ------ Shared Memory Limits --------
#    max number of segments = 4096               // SHMMNI. Maximum number of shared memory segments system-wide.	
#                                                // 256 * <RAM_GB>   
#    max seg size (kbytes) = 32768               // SHMMAX. Maximum size of shared memory segment (kbytes).
#                                                // Should be half of? available RAM, in kbytes.
#    max total shared memory (kbytes) = 8388608  // SHMALL. Total amount of shared memory available (bytes or pages).
#                                                // If bytes, same as SHMMAX; if pages, ceil(SHMMAX/PAGE_SIZE)
#                                                // 2 * <size of RAM in the default system page size>
#                                                // Use getconf PAGE_SIZE to verify PAGE_SIZE (usually 4096)
#    min seg size (bytes) = 1
# 
#    ------ Semaphore Limits --------
#    max number of arrays = 1024                 // SEMMNI. A system-wide limit on the maximum number of semaphore identifiers (sempahore sets)
#    max semaphores per array = 250              // SEMMSL. The maximum number of semaphores in a sempahore set.   
#    max semaphores system wide = 256000         // SEMMNS. A system-wide limit on the number of semaphores in all semaphore sets. The maximum number of sempahores in the system.
#    max ops per semop call = 32                 // SEMOPM. The maximum number of operations in a single semop call.
#    semaphore max value = 32767
# 
# -> cat /proc/sys/kernel/sem
# SEMMSL SEMMNS SEMOPM SEMMNI

set_kernel_limits() {
  echo "Setting Kernel limits"
  local mem_total_gb=$(free -g | grep Mem | awk '{ print $2 }') 
  if [[ ${mem_total_gb} == 0 ]]; then
    local shmmax=$((1024*512)) 
  else
    local shmmax=$((${mem_total_gb}/2*1024*1024)) 
  fi
  local page_size=$(getconf PAGE_SIZE)
  local semmns=512000
  local shmmni=4096    
  local shmall=$((${shmmax}/${page_size})) 
  local msgmni=1024

  echo "Available memory is ${mem_total_gb} Gbytes"
  echo "Pagesize is ${page_size}"  
  echo "semmns is ${semmns}"
  echo "shmmni is ${shmmni}"
  echo "shmmax is ${shmmax}"
  echo "shmall is ${shmall}"

  echo "kernel.msgmni=${msgmni}" | sudo tee -a /etc/sysctl.conf
  echo "kernel.msgmnb=65536" | sudo tee -a /etc/sysctl.conf
  echo "kernel.msgmax=65536" | sudo tee -a /etc/sysctl.conf
  echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.conf
    
  echo "kernel.sem=250 ${semmns} 256 ${shmmni}" | sudo tee -a /etc/sysctl.conf  
  echo "kernel.shmmax=${shmmax}" | sudo tee -a /etc/sysctl.conf
  echo "kernel.shmall=${shmall}" | sudo tee -a /etc/sysctl.conf
  sysctl -p  

}

set_kernel_limits