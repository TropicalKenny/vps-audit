#!/usr/bin/env bash
set -Eeuo pipefail

echo "=== DREADED RUNNER GOOGLE CHROME INSTALL ==="
date -u
hostname
df -h /

if [[ ! -x /usr/bin/google-chrome && ! -x /usr/bin/google-chrome-stable ]]; then
  sudo -n apt-get update -qq
  sudo -n DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl xdg-utils
  tmpdeb=/tmp/google-chrome-stable_current_amd64.deb
  curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o "$tmpdeb"
  sudo -n DEBIAN_FRONTEND=noninteractive apt-get install -y "$tmpdeb"
  rm -f "$tmpdeb"
fi

browser=''
for candidate in /usr/bin/google-chrome /usr/bin/google-chrome-stable; do
  if [[ -x "$candidate" ]]; then browser="$candidate"; break; fi
done
test -n "$browser"
echo "browser=$browser"
"$browser" --version

echo "=== HEADLESS SMOKE ==="
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
"$browser" --headless=new --no-sandbox --disable-gpu --user-data-dir="$tmpdir" --dump-dom 'data:text/html,<title>dreaded-runner-browser-ok</title><p>ok</p>' | grep -q '<p>ok</p>'
echo "headless_browser=ok"

echo "=== RUNNER SERVICE ==="
systemctl is-active actions.runner.TropicalKenny-Dreadedelectricwebsite.dreaded-preview-vps-0868c90c.service
echo "=== PROTECTED SERVICES ==="
docker inspect --format='dreaded_container={{.State.Status}}/{{if .State.Health}}{{.State.Health.Status}}{{else}}no-health{{end}}' dreaded-electric-production 2>/dev/null || true
test -f /home/ubuntu/state/dreaded-electric/production/db/dreaded.sqlite && echo "dreaded_production_db=present"
test -d /home/ubuntu/workspace/aurent-state/live/repos/dream-destinations/.git && echo "dream_repo=present"
