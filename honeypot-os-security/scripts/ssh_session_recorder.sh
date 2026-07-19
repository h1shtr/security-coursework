#!/bin/bash
# Records a full, replayable transcript of an SSH session.
# Wire in via sshd_config: ForceCommand /usr/local/bin/ssh_session_recorder.sh

LOG_DIR="/var/log/ssh-sessions"
mkdir -p "$LOG_DIR"

USER=$(whoami)
DATE=$(date +"%Y%m%d_%H%M%S")
SESSION_FILE="$LOG_DIR/${USER}_${DATE}.log"

exec /usr/bin/script -qf --timing="$LOG_DIR/${USER}_${DATE}.timing" "$SESSION_FILE"
