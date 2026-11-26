#!/usr/bin/env bash
# ---------------------------------------------
# task-menu.sh — browse and open tasks from notes
# ---------------------------------------------

NOTES="$HOME/notes"
BUFFER="$NOTES/buffer"

TERMINAL="kitty"


# check that notes folder exists
[ -d "$NOTES" ] || { fuzzel -d --log-level error -p "Notes folder not found" ; exit 1; }

TASKS=$(rg '\s\[[\sx-]\]\s' "$NOTES" --line-number --no-heading 2>/dev/null | cut -d/ -f5- )
[ -z "$TASKS" ] && { echo "No tasks found."; exit 0; }

SELECTED=$(echo "$TASKS" | fuzzel --dmenu --lines 25 --width 100 --log-level error --prompt "Select task:" )
[ -z "$SELECTED" ] && exit 0  # user pressed Esc

FILE="$NOTES/$(echo "$SELECTED" | cut -d: -f1)"
echo $FILE
LINE=$(echo "$SELECTED" | cut -d: -f2)

cd "$NOTES"
$TERMINAL -e nvim "$FILE"
