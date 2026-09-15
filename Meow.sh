#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ID="$(gcloud config get-value project 2>/dev/null || true)"
if [[ -z "$PROJECT_ID" || "$PROJECT_ID" == "(unset)" ]]; then
  PROJECT_ID="$(gcloud projects list --format='value(projectId)' --filter='projectId~^qwiklabs-gcp-' --limit=1)"
fi
[[ -n "$PROJECT_ID" ]] || { echo "ERROR: Lab project nahi mila." >&2; exit 1; }
gcloud config set project "$PROJECT_ID" >/dev/null

INSTANCE="myinstance"
REGION="asia-southeast1"
ZONE="asia-southeast1-b"
ROOT_PASSWORD="QwikLab-$(openssl rand -hex 8)!"

log() { printf '\n\033[1;36m[%s]\033[0m %s\n' "$(date +%H:%M:%S)" "$*"; }

log "Cloud SQL Admin API enable kar raha hoon"
gcloud services enable sqladmin.googleapis.com --quiet

if ! gcloud sql instances describe "$INSTANCE" >/dev/null 2>&1; then
  log "MySQL 8 instance create kar raha hoon"
  gcloud sql instances create "$INSTANCE" \
    --database-version=MYSQL_8_0 \
    --tier=db-custom-4-16384 \
    --storage-size=100 \
    --storage-type=SSD \
    --region="$REGION" \
    --availability-type=regional \
    --zone="$ZONE" \
    --root-password="$ROOT_PASSWORD" \
    --quiet
else
  log "Existing myinstance reuse kar raha hoon"
  gcloud sql users set-password root \
    --host=% \
    --instance="$INSTANCE" \
    --password="$ROOT_PASSWORD" \
    --quiet || true
fi

log "Instance RUNNABLE hone ka wait kar raha hoon"
for attempt in {1..30}; do
  state="$(gcloud sql instances describe "$INSTANCE" --format='value(state)')"
  [[ "$state" == "RUNNABLE" ]] && break
  printf 'State: %s (attempt %s/30)\n' "$state" "$attempt"
  sleep 10
done

state="$(gcloud sql instances describe "$INSTANCE" --format='value(state)')"
[[ "$state" == "RUNNABLE" ]] || { echo "ERROR: Cloud SQL instance RUNNABLE nahi hua." >&2; exit 1; }

log "guestbook database aur sample data create kar raha hoon"
cat > /tmp/gsp151.sql <<'SQL'
CREATE DATABASE IF NOT EXISTS guestbook;
USE guestbook;
CREATE TABLE IF NOT EXISTS entries (
  guestName VARCHAR(255),
  content VARCHAR(255),
  entryID INT NOT NULL AUTO_INCREMENT,
  PRIMARY KEY(entryID)
);
DELETE FROM entries;
INSERT INTO entries (guestName, content) VALUES ('first guest', 'I got here!');
INSERT INTO entries (guestName, content) VALUES ('second guest', 'Me too!');
SELECT * FROM entries;
SQL

MYSQL_PWD="$ROOT_PASSWORD" gcloud sql connect "$INSTANCE" --user=root --quiet < /tmp/gsp151.sql

log "Verification"
gcloud sql instances describe "$INSTANCE" \
  --format='table(name,databaseVersion,region,settings.tier,settings.availabilityType,state)'
printf '\nDatabase guestbook aur entries table/data create ho gaya.\n'
printf 'Root password used by this script: %s\n' "$ROOT_PASSWORD"
printf 'Skills Boost page par 30-60 seconds wait karke Check my progress click karein.\n'
