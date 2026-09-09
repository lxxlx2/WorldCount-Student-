#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${1:-Terminal}"
OUT="${2:?usage: $0 <App Name> <output.png>}"
mkdir -p "$(dirname "$OUT")"

# Bring the target application to the front. This only captures an actual on-screen window.
osascript -e "tell application \"$APP_NAME\" to activate" >/dev/null 2>&1 || true
sleep 0.8

WINDOW_ID="$(osascript <<OSA 2>/dev/null || true
 tell application "System Events"
   tell process "$APP_NAME"
     if (count of windows) is 0 then return ""
     try
       return value of attribute "AXWindowNumber" of window 1
     on error
       return ""
     end try
   end tell
 end tell
OSA
)"

if [[ "$WINDOW_ID" =~ ^[0-9]+$ ]]; then
  screencapture -x -l "$WINDOW_ID" "$OUT"
else
  echo "无法自动取得 $APP_NAME 的窗口编号。请在出现十字光标后点击要保存的真实窗口。" >&2
  screencapture -i -W "$OUT"
fi

if [[ ! -s "$OUT" ]]; then
  echo "ERROR: screenshot was not created: $OUT" >&2
  exit 1
fi

echo "$OUT"
