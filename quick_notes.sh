#!/usr/bin/env bash

FOLDER="$HOME/notes"
BUFFER_FOLDER="$FOLDER/buffer"
TERMINAL="kitty"

# EDITOR="zed $FOLDER"
EDITOR="$TERMINAL -e nvim"

# ---- sanity check ----
if [ ! -d "$FOLDER" ]; then
    echo "Error: $FOLDER does not exist." | fuzzel -d --log-level=error
    exit 1
fi

# create buffer folder if it doesn't exist
mkdir -p "$BUFFER_FOLDER"

cd "$FOLDER" || exit 1

# ---- new note creation ----
newnote() {
    local dir name file date_suffix

    # allowed folders
    allowed=("buffer" "projects" "areas" "resources" "archive" ".")

    # select folder (default buffer, PARA folders only)
    dir=$(
        printf "buffer\nprojects\nareas\nresources\narchive\n" |
        fuzzel --log-level=error --dmenu --lines 10 --width 60 \
            --prompt "Where does this belong? (default: buffer, type . for root)"
    )

    # exit if Esc pressed
    [ -z "$dir" ] && exit 0

    # check if dir is in allowed folders; if not, just call fuzzel and exit
    if [[ ! " ${allowed[@]} " =~ " ${dir} " ]]; then
        # optional: give a quick prompt to let user know they typed something invalid
        fuzzel --log-level=error --dmenu --lines 1 --width 60 --prompt "Invalid folder. Press Return to exit." >/dev/null
        exit 0
    fi

    # make sure directory exists
    mkdir -p "$dir"

        # select note name
    name=$(
        fuzzel --log-level=error --dmenu --lines 0 --width 60 \
            --prompt "Note name (empty = today)"
    ) || exit 0

    [ -z "$name" ] && name="$(date +%Y-%m-%d)"

    # append date if creating note in buffer folder
    if [[ "$dir" == "buffer" && "$name" != "$(date +%Y-%m-%d)" ]]; then
        date_suffix=$(date +%Y-%m-%d)
        name="${name}_${date_suffix}"
    fi
    file="$dir/$name.md"
    mkdir -p "$dir"
    touch "$file"

    $EDITOR "$file"
}

function date_buffer {

    # check if argument is sent
    local argg=$1

    # #don't need this block, as ' is now used to add to general buffer.
    # local input task days file_name target_date
    # if [ -z "$argg" ]; then
    #     input=$(
    #         fuzzel --log-level=error --dmenu -l 0 --width  110 -p "Quick note (+N for future, e.g., +3 Task): "\
    #         # wmenu -p "Quick note (+N for future, e.g., +3 Task): " \
    #     ) || exit 0;

    # else input="$argg"
    # fi

    input="$argg"

    [ -z "$input" ] && exit 0

    # Check for +N pattern at the start of the string
    if [[ "$input" =~ ^\+([0-9]+)\ (.*) ]]; then
        days="${BASH_REMATCH[1]}"
        task="${BASH_REMATCH[2]}"
        target_date=$(date -d "+$days days" +%Y-%m-%d)
    else
        task="$input"
        target_date=$(date +%Y-%m-%d)
    fi

    file_name="$target_date.md"

    # Ensure file exists and has header if new
    touch "$BUFFER_FOLDER/$file_name"
    [ ! -s "$BUFFER_FOLDER/$file_name" ] && echo "----" > "$BUFFER_FOLDER/$file_name"

    # Prepend task
    sed -i "1i - [ ] $task" "$BUFFER_FOLDER/$file_name"

    notify-send "Added to $target_date" "$(echo "$task" | cut -c1-40)…" 2>/dev/null
}

# ---- main note/task selector ----
selected() {
    local SELECTION DATE

    SELECTION=$(
        printf "[New Note]\n%s\n" \
        "$(find . \( -path '*/.*' -o -path './archive' \) -prune -o -name '*.md' \
        -printf '%T@ %P\n' \
            | sort -nr \
            | cut -d' ' -f2-)" |
            # bemenu -i -l 10  -p "Select note or type task:"
            fuzzel --log-level=error -d --width 100 --lines 12 -p "open | type task = dated buffer | 'task = general buffer:" \
    ) || exit 0

    case "$SELECTION" in
        "[New Note]")
            newnote
            ;;
        *.md)
             $EDITOR "$SELECTION"
            ;;
        "")
            exit 0
            ;;
        *)
            local today=$(echo "$SELECTION" | cut -c1)
            local first_char="${SELECTION:0:1}"
            if [[ "$first_char" == "'" ]]; then

                    # prepend timestamp to buffer.md entry

                    local task="${SELECTION:1}"
                    file_name="buffer.md"

                    if [[ "$task" == '' ]]; then
                        $EDITOR "$BUFFER_FOLDER/$file_name"
                        exit 0
                    fi

                    # Ensure file exists and has header if new
                    touch "$BUFFER_FOLDER/$file_name"
                    [ ! -s "$BUFFER_FOLDER/$file_name" ] && echo "----" > "$BUFFER_FOLDER/$file_name"

                    DATE="$(date +%Y-%m-%d)"
                    # tmp=$(echo "- [ ] $SELECTION-")
                    # tmp="$tmp$DATE"
                    # echo $SELECTION

                    # Prepend task
                    sed -i "1i - [ ] ${task}_${DATE}" "$BUFFER_FOLDER/$file_name"

                    notify-send "Added to buffer" "$(echo "$task" | cut -c1-40)…" 2>/dev/null

            else
                task="${SELECTION}"
                date_buffer "$task"
                exit 0
            fi
            ;;
    esac
}

# ---- run ----
selected
