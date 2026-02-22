#!/usr/bin/env bash
# Fetch a URL via Zyte API with browser rendering (client-side JS)
# Usage: zyte_fetch.sh <url> [--http] [--screenshot] [--output FILE]
#
# Options:
#   --http        Use HTTP mode instead of browser rendering
#   --screenshot  Return a screenshot (base64 PNG)
#   --output FILE Write output to FILE instead of stdout
#   --raw-json    Output raw JSON response

set -euo pipefail

API_KEY_FILE="${ZYTE_API_KEY_FILE:-$HOME/.config/zyte/api_key}"
API_KEY="$(cat "$API_KEY_FILE" 2>/dev/null)" || { echo "Error: API key not found at $API_KEY_FILE" >&2; exit 1; }

URL=""
MODE="browser"
SCREENSHOT=false
OUTPUT=""
RAW_JSON=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --http) MODE="http"; shift ;;
    --screenshot) SCREENSHOT=true; shift ;;
    --output) OUTPUT="$2"; shift 2 ;;
    --raw-json) RAW_JSON=true; shift ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) URL="$1"; shift ;;
  esac
done

[[ -z "$URL" ]] && { echo "Usage: zyte_fetch.sh <url> [--http] [--screenshot] [--output FILE]" >&2; exit 1; }

# Build JSON payload
if [[ "$MODE" == "browser" ]]; then
  if [[ "$SCREENSHOT" == true ]]; then
    PAYLOAD=$(jq -n --arg url "$URL" '{"url": $url, "browserHtml": true, "screenshot": true}')
  else
    PAYLOAD=$(jq -n --arg url "$URL" '{"url": $url, "browserHtml": true}')
  fi
else
  PAYLOAD=$(jq -n --arg url "$URL" '{"url": $url, "httpResponseBody": true}')
fi

RESPONSE=$(curl -s --compressed \
  --user "${API_KEY}:" \
  --header 'Content-Type: application/json' \
  --data "$PAYLOAD" \
  https://api.zyte.com/v1/extract)

# Check for errors
if echo "$RESPONSE" | jq -e '.type' >/dev/null 2>&1; then
  echo "Zyte API error:" >&2
  echo "$RESPONSE" | jq . >&2
  exit 1
fi

if [[ "$RAW_JSON" == true ]]; then
  RESULT="$RESPONSE"
elif [[ "$MODE" == "browser" ]]; then
  RESULT=$(echo "$RESPONSE" | jq -r '.browserHtml')
else
  RESULT=$(echo "$RESPONSE" | jq -r '.httpResponseBody' | base64 --decode)
fi

if [[ -n "$OUTPUT" ]]; then
  echo "$RESULT" > "$OUTPUT"
  echo "Written to $OUTPUT" >&2
else
  echo "$RESULT"
fi

# If screenshot was requested, save it separately
if [[ "$SCREENSHOT" == true && "$RAW_JSON" != true ]]; then
  SCREENSHOT_FILE="${OUTPUT:-screenshot}.png"
  [[ -n "$OUTPUT" ]] && SCREENSHOT_FILE="${OUTPUT%.html}.png"
  echo "$RESPONSE" | jq -r '.screenshot' | base64 --decode > "$SCREENSHOT_FILE"
  echo "Screenshot saved to $SCREENSHOT_FILE" >&2
fi
