#!/bin/bash
# Sends a Telegram alert with session details whenever an SSH login succeeds.
# Intended to be wired in via PAM (e.g. pam_exec) so it fires on every login.

# === Telegram Bot Info ===
# Fill these in with your own bot's credentials (create one via @BotFather).
# Never commit real values here.
TOKEN="YOUR_TELEGRAM_BOT_TOKEN"
CHAT_ID="YOUR_TELEGRAM_CHAT_ID"

# === Session Info ===
USER_NAME="$PAM_USER"
IP_ADDRESS=$(echo "$SSH_CONNECTION" | awk '{print $1}')
HOSTNAME=$(hostname)
LOGIN_TIME=$(date '+%Y-%m-%d %H:%M:%S')
TTY=$(tty)
PID=$$

# === GeoIP Lookup ===
GEOINFO=$(geoiplookup "$IP_ADDRESS" | awk -F: '{print $2}' | xargs)

# === Alert Message ===
MESSAGE="SSH Login Alert%0A%0AUser: $USER_NAME%0AIP: $IP_ADDRESS%0AHostname: $HOSTNAME%0ATime: $LOGIN_TIME%0ATTY: $TTY%0ASession PID: $PID%0AGeoIP: $GEOINFO"

# === Send Alert ===
curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
  -d "chat_id=${CHAT_ID}" \
  -d "text=${MESSAGE}"
