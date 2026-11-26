# Making it work
A log of addons and scripts I made for my system. and avoid writing configs as muchs as possible.

## Projects
### Done
### working
- [ ] setup mpv
  - [x] install
- [x] Fuzzel-based Note Search
  - [ ] get rid of all the sed
  - [x] Quick buffer capture
    - [x] Timestamped buffer entries
    - [x] use ' for adding task to today's buffer note. (now ' adds to the general buffer)
      - [x] find a way to [push arguments to functions](resources/shell_and_scripting.md#push-arguments-to-functions) , till then
      - [x] implement the push arguments things
  - [x] `newnote()` script
  - [x] Recent notes selector
  - [x] PARA folder structure integration
### wishlist
  - *what i wish was there*
	- [ ] the [New Note] option made second on the list so that pressing enter will directly open the last edited note.
- [ ] Clipboard Manager (cliphist + fuzzel)
    - not doing it
- [ ] Note Taking Setup (VimWiki + Neovim)
  - not doing it
- [ ] Quick Actions Dynamic Menu

## Installs
- **sox**
  to play sounds via scipts
- **[fuzzel](https://codeberg.org):** Wayland-native dynamic menu/launcher.
- **[copyQ](https://hluk.github.io/CopyQ/):** Clipboard manager.
    | Keybindings | Console command |
    |------------|----------------|
    | `Super + V` | Show window |
    | `<C-F12>`  | Next item |
    | `<C-Sht-F12>` | Previous item |

  > *Use `copyq --help` in terminal to see all commands.*
  
- **kitty**
  - the terminal emulator

  - configs
    - hit \<CS-F12\> to open config file
    - [it'sFoss blog](https://itsfoss.com/kitty-customization/)
      - `shell /usr/bin/fish`
      - `hide_window_decorations yes`
- **the editor**

    | Keybindings | Console command |
    |------------|----------------|
    | < alt-tilde > | toggle vim mode |
    
  - [Zed](https://zed.dev/)
  - **code**
  - **Neovim**
	  - using `astronvim`
	  - added render-markdown plugin
	  - \<leader\>tt to toggle completion of markdown tasks.
    > 
- **[Syncthing](https://syncthing.net/)**

- [NVIM](resources/shell_and_scripting.md#NVIM)
    - using appimage stored in `~/Dev`. a symlink in ~/.local/bin/nvim

## [scripts](resources/shell_and_scripting.md)

### audio_sink_choose
- **Description:** Quickly switch default PipeWire audio output (sink) using a fuzzy-search menu.
- **Location:** `~/Dev/scripts/audio_sink_choose` (linked to `~/Dev/scripts/bin/`)
- **Key Binding:** `Super + Alt + A`
- **Dependencies:** `wireplumber` (`wpctl`), `grep` (pcre), `sed`.
- **stuff i wish** 
  - switch before the menu apprears.

### quick_notes ([[PARA_method]] + Buffer System)
- **quirks**
  - the buffer.md file needs to have something in it for `sed` to write to it. it fucking exits w/o errors, script doesn't let sed touch an empty file though.
- **Description:** Fuzzy search - note management system:
  - Lists all .md notes (sorted by last modified time) with a [New Note] option.
  - Supports PARA folder structure: projects, areas, resources, archive, plus buffer/.
  - [New Note] flow:
    - Prompts for destination folder (defaults to buffer).
    - Prompts for note name (defaults to today’s date).
    - Notes created in buffer/ get a date suffix if not date-named.
    - Newly created notes are opened immediately.
  - Apostrophe-prefixed capture ('task):
    - Arbitrary text input is prepended to buffer/buffer.md with today’s date.
    - when entered a task it will be format as: - [ ] task_YYYY-MM-DD
  - Quick task capture:
    - Sends task to a dated buffer note (buffer/YYYY-MM-DD.md).
    - Supports future scheduling using +N task syntax.
      - +N task prepends the task to buffer/<today+N>.md.
      - `+2 Buy groceries` → goes into buffer/<today+2>.md
- **Location:** `~/Dev/scripts/notes_launcher` (linked to `~/Dev/scripts/bin/`)
- **Key Binding:** `Super + Alt + Q`
- **Dependencies:** `fuzzel`, `zed` (or another editor), `notify-send`, standard bash utilities (`find`, `sed`, `mkdir`, `date`).

### tasks
*an extension to the quick notes script*
- **Description**
  - to list all the task in the dynamic menu and open the selected task's file wiht cursor on it's line.
  - grep for '\s\[\[\sx]\]\s' in the notes folder
### timer
- simple timer, 
  - `timer 15` will set a 15 min timer
  - if the duration is more than 24 mins, the timer will have a 10 mins to finish warning.
  
## Path
*Keeping track of manually added Paths*
- ~/Dev/scripts/bin

### Daily shut down timer
***not made yet, prolly never doing it***
Create the Service File:
Run sudo nano /etc/systemd/system/daily-shutdown.service and paste:
ini

```bash
[Unit]
Description=Automatic Daily Shutdown

[Service]
Type=oneshot
ExecStart=/usr/bin/systemctl poweroff
```

कोड सावधगिरीने वापरा.
Create the Timer File:
Run sudo nano /etc/systemd/system/daily-shutdown.timer and paste:
ini
```bash
[Unit]
Description=Run Daily Shutdown at 11 PM

[Timer]
OnCalendar=*-*-* 23:00:00
Persistent=true

[Install]
WantedBy=timers.target
```
कोड सावधगिरीने वापरा.
Enable and Start:
bash
```bash
sudo systemctl enable --now daily-shutdown.timer
```
