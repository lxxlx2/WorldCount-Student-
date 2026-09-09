#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${1:-Terminal}"
OUT="${2:?usage: $0 <App Name> <output.png>}"
mkdir -p "$(dirname "$OUT")"

# Bring the target application to the front. We capture only real on-screen content.
osascript -e "tell application \"$APP_NAME\" to activate" >/dev/null 2>&1 || true
sleep 0.8

# AXWindowNumber is no longer reliably exposed on newer macOS releases.
# Read the front window's position and size through Accessibility and capture that region.
BOUNDS="$(osascript <<OSA 2>/dev/null || true
 tell application "System Events"
   tell process "$APP_NAME"
     if (count of windows) is 0 then return ""
     try
       set p to position of front window
       set s to size of front window
       return (item 1 of p as text) & "," & (item 2 of p as text) & "," & (item 1 of s as text) & "," & (item 2 of s as text)
     on error
       return ""
     end try
   end tell
 end tell
OSA
)"

if [[ "$BOUNDS" =~ ^-?[0-9]+,-?[0-9]+,[0-9]+,[0-9]+$ ]]; then
  IFS=',' read -r X Y W H <<< "$BOUNDS"
  if screencapture -x -R"$X,$Y,$W,$H" "$OUT" 2>/dev/null && [[ -s "$OUT" ]]; then
    echo "$OUT"
    exit 0
  fi
fi

# Final automatic fallback: capture the real current display. Never synthesize a terminal image
# and never block waiting for interactive crosshair input.
echo "WARNING: 无法读取 $APP_NAME 的窗口边界，改为自动截取当前真实屏幕。" >&2
screencapture -x "$OUT"

if [[ ! -s "$OUT" ]]; then
  echo "ERROR: screenshot was not created: $OUT" >&2
  exit 1
fi

echo "$OUT"
