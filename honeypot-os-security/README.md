# Linux Honeypot with Multi-Tool Intrusion Monitoring

**Course:** FC254 – Operating System Security, University of Prince Mugrin
**Instructor:** Dr. Syed Sadiq

## Overview

This project builds a deliberately weakened Ubuntu 22.04 VM (default firewall, AppArmor,
and auto-update protections disabled) and instruments it with a stack of open-source
monitoring tools so that attacker behavior can be observed and recorded in real time,
without interfering with the attack.

## Objectives

- Stand up a purposely vulnerable Linux "honeypot" host
- Record every SSH session in full for later forensic review
- Track file, process, and syscall activity with host-based monitoring tools
- Push real-time alerts (via a Telegram bot) whenever someone logs in
- Flag malware/rootkit indicators automatically

## Tools Used

| Tool | Purpose |
|---|---|
| OSSEC | Host intrusion detection: log analysis, file integrity monitoring |
| auditd | Syscall auditing, sensitive-file monitoring |
| inotify-tools | Real-time filesystem change detection |
| psacct (acct) | Per-user command/activity accounting |
| rkhunter | Rootkit and backdoor detection |
| Lynis | General security auditing and hardening recommendations |
| Suricata | Network IDS/IPS |
| ClamAV | Signature-based malware scanning |
| Falco | Kernel-event-based runtime anomaly detection |
| Telegram Bot API | Real-time SSH login alerting |

## What's in this repo

- [`report/FC254_Project.pdf`](report/FC254_Project.pdf) – full write-up: installation steps,
  configuration, and testing evidence for every tool above
- [`scripts/ssh_login_alert.sh`](scripts/ssh_login_alert.sh) – PAM-triggered script that sends
  a Telegram alert (user, IP, hostname, GeoIP) on every successful SSH login
- [`scripts/ssh_session_recorder.sh`](scripts/ssh_session_recorder.sh) – `ForceCommand` script
  that records a full replayable transcript (`script` + `--timing`) of every SSH session

> **Note:** the alert script's Telegram token/chat ID placeholders must be filled in with your
> own bot credentials — see [BotFather](https://core.telegram.org/bots#botfather) to create one.

## Testing Summary

- Nmap SYN scans and DHCP fingerprinting from an attacker VM were detected by Suricata
- An EICAR test file was correctly flagged by ClamAV
- Unauthorized edits to `/etc/passwd` and `/etc/sudoers` were logged by auditd, OSSEC, and Falco
- `lastcomm` (psacct) reconstructed a full command history for the session
- Full SSH session transcripts and live Telegram alerts were confirmed working end to end

## Strengths & Limitations

**Strengths:** realistic attacker interaction, broad visibility from lightweight tools, live alerting.

**Limitations:** no automated incident response (detection only), no centralized SIEM/dashboard,
and the Telegram bot token must be kept secret since it's the only thing gating the alert channel.

## Author

Hisham Bai (group coursework, FC254 — Operating System Security)
