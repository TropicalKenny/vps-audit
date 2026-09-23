#!/usr/bin/env bash
set -Eeuo pipefail

echo "=== DREADED RUNNER BROWSER INSTALL ==="
date -u
hostname
df -h /

if command -v chromium >/dev/null 2>&1; then
  echo "browser=$(command -v chromium)"
  chromium --version
  exit 0
fi
if command -v google-chrome >/dev/null 2>&1; then
  echo "browser=$(command -v google-chrome)"
  google-chrome --version
  exit 0
fi

sudo -n apt-get update -qq

if apt-cache show chromium >/dev/null 2>&1; then
  sudo -n DEBIAN_FRONTEND=noninteractive apt-get install -y chromium
elif apt-cache show chromium-browser >/dev/null 2>&1; then
  sudo -n DEBIAN_FRONTEND=noninteractive apt-get install -y chromium-browser
else
  tmpdeb=/tmp/google-chrome-stable_current_amd64.deb
  curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o "$tmpdeb"
  sudo -n DEBIAN_FRONTEND=noninteractive apt-get install -y "$tmpdeb"
  rm -f "$tmpdeb"
fi

browser=''
for candidate in /usr/bin/chromium /usr/bin/chromium-browser /usr/bin/google-chrome /usr/bin/google-chrome-stable; do
  if [[ -x "$candidate" ]]; then browser="$candidate"; break; fi
done
test -n "$browser"
echo "browser=$browser"
"$browser" --version

echo "=== RUNNER SERVICE ==="
systemctl is-active actions.runner.TropicalKenny-Dreadedelectricwebsite.dreaded-preview-vps-0868c90c.service
echo "=== PROTECTED SERVICES ==="
docker inspect --format='dreaded_container={{.State.Status}}/{{if .State.Health}}{{.State.Health.Status}}{{else}}no-health{{end}}' dreaded-electric-production 2>/dev/null || true
test -f /home/ubuntu/state/dreaded-electric/production/db/dreaded.sqlite && echo "dreaded_production_db=present"
test -d /home/ubuntu/workspace/aurent-state/live/repos/dream-destinations/.git && echo "dream_repo=present"
