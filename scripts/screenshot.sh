#!/usr/bin/env bash
# Screenshot helper for kimi-webbridge
# Decodes base64 image data and saves to disk, returning only the file path.
# Usage:
#   bash screenshot.sh [-s session] [-o output_path] [-f png|jpeg] [-q quality]

set -euo pipefail

SESSION="url-summarize"
FORMAT="png"
QUALITY=80
OUTPUT=""

while getopts "s:o:f:q:" opt; do
  case $opt in
    s) SESSION="$OPTARG" ;;
    o) OUTPUT="$OPTARG" ;;
    f) FORMAT="$OPTARG" ;;
    q) QUALITY="$OPTARG" ;;
    *) echo "Usage: $0 [-s session] [-o output] [-f png|jpeg] [-q quality]" >&2; exit 1 ;;
  esac
done

TMPDIR_BASE="${TMPDIR:-/tmp}/kimi-webbridge-screenshots"
mkdir -p "$TMPDIR_BASE"

if [ -z "$OUTPUT" ]; then
  OUTPUT="$TMPDIR_BASE/$(date +%Y%m%d_%H%M%S).$FORMAT"
fi

RESPONSE=$(curl -s -X POST http://127.0.0.1:10086/command \
  -H 'Content-Type: application/json' \
  -d "{\"action\":\"screenshot\",\"args\":{\"format\":\"$FORMAT\",\"quality\":$QUALITY},\"session\":\"$SESSION\"}")

# Extract base64 data
DATA=$(echo "$RESPONSE" | grep -o '"data":"[^"]*"' | sed 's/"data":"//;s/"$//' | tr -d '\n')

if [ -z "$DATA" ]; then
  echo "Error: No screenshot data received" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

echo "$DATA" | base64 -d > "$OUTPUT"
echo "$OUTPUT"
