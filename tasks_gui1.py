#!/usr/bin/env python3
import tkinter as tk
from tkinter import simpledialog, messagebox
from pathlib import Path
from datetime import date
import subprocess

# Path to your buffer folder
BUFFER = Path.home() / "notes/buffer"

# ------------------ Task Handling ------------------

def parse_tasks():
    buffer_tasks, prev, today_tasks, future = [], [], [], []
    today_str = date.today().strftime("%Y-%m-%d")

    for file in BUFFER.glob("*.md"):
        file_date = file.stem
        with open(file) as f:
            for line in f:
                line = line.strip()
                if line.startswith("- [ ]") or line.startswith("- [x]"):
                    if file_date == "buffer":
                        buffer_tasks.append((file, line))
                    elif file_date < today_str:
                        prev.append((file, line))
                    elif file_date == today_str:
                        today_tasks.append((file, line))
                    else:
                        future.append((file, line))
    return buffer_tasks, prev, today_tasks, future

def save_tasks():
    all_lists = [tasks_buffer, tasks_prev, tasks_today, tasks_future]
    files_content = {}
    for lst in all_lists:
        for file, line in lst:
            files_content.setdefault(file, []).append(line)
    for file, lines in files_content.items():
        with open(file, "w") as f:
            f.write("\n".join(lines) + "\n")

def refresh_listboxes():
    for lb, lst, color in zip(
        [lb_buffer, lb_prev, lb_today, lb_future],
        [tasks_buffer, tasks_prev, tasks_today, tasks_future],
        ["white", "light gray", "light green", "light blue"]
    ):
        lb.delete(0, tk.END)
        for _, line in lst:
            lb.insert(tk.END, line)
        lb.configure(bg=color)

# ------------------ Task Actions ------------------

def complete_task(lb, lst):
    sel = lb.curselection()
    if sel:
        i = sel[0]
        file, line = lst[i]
        lst[i] = (file, line.replace("- [ ]", "- [x]"))
        refresh_listboxes()

def delete_task(lb, lst):
    sel = lb.curselection()
    if sel:
        i = sel[0]
        del lst[i]
        refresh_listboxes()

def move_task(lb, lst):
    sel = lb.curselection()
    if not sel:
        return
    i = sel[0]
    date_input = simpledialog.askstring(
        "Move Task",
        "Enter new date (natural language, e.g., 'tomorrow', '+3 days', 'next Monday'):"
    )
    if not date_input:
        return

    try:
        # Use system date command to parse natural language
        result = subprocess.run(
            ["date", "-d", date_input, "+%Y-%m-%d"],
            capture_output=True, text=True, check=True
        )
        new_date = result.stdout.strip()
    except subprocess.CalledProcessError:
        messagebox.showerror("Invalid Date", f"Could not parse date: {date_input}")
        return

    file, line = lst[i]
    new_file = BUFFER / f"{new_date}.md"
    lst[i] = (new_file, line)
    refresh_listboxes()

def open_task(lb, lst):
    # Open selected task in zed
    sel = lb.curselection()
    if sel:
        i = sel[0]
        file, _ = lst[i]
        subprocess.Popen(["zed", str(file)])

# ------------------ Load Tasks ------------------

tasks_buffer, tasks_prev, tasks_today, tasks_future = parse_tasks()

# ------------------ GUI Setup ------------------

root = tk.Tk()
root.title("Task Dashboard")

frame = tk.Frame(root)
frame.pack(padx=10, pady=10)

# ---------- Helper to make buttons ----------
def make_buttons(frame, lb, lst):
    tk.Button(frame, text="Complete", command=lambda: complete_task(lb, lst)).pack(side=tk.LEFT, padx=3)
    tk.Button(frame, text="Delete", command=lambda: delete_task(lb, lst)).pack(side=tk.LEFT, padx=3)
    tk.Button(frame, text="Move", command=lambda: move_task(lb, lst)).pack(side=tk.LEFT, padx=3)

# ---------- Row 1: Buffer Tasks ----------
frame_buffer = tk.Frame(frame)
frame_buffer.grid(row=0, column=0, columnspan=3, padx=5, pady=5)
tk.Label(frame_buffer, text="Buffer Tasks").pack()
lb_buffer = tk.Listbox(frame_buffer, width=120, height=10)
lb_buffer.pack()
lb_buffer.bind("<Double-Button-1>", lambda e: open_task(lb_buffer, tasks_buffer))
make_buttons(frame_buffer, lb_buffer, tasks_buffer)

# ---------- Row 2: Previous / Today / Future ----------
# Previous
frame_prev = tk.Frame(frame)
frame_prev.grid(row=1, column=0, padx=5, pady=5)
tk.Label(frame_prev, text="Previous Days").pack()
lb_prev = tk.Listbox(frame_prev, width=40, height=15)
lb_prev.pack()
lb_prev.bind("<Double-Button-1>", lambda e: open_task(lb_prev, tasks_prev))
make_buttons(frame_prev, lb_prev, tasks_prev)

# Today
frame_today = tk.Frame(frame)
frame_today.grid(row=1, column=1, padx=5, pady=5)
tk.Label(frame_today, text="Today").pack()
lb_today = tk.Listbox(frame_today, width=40, height=15)
lb_today.pack()
lb_today.bind("<Double-Button-1>", lambda e: open_task(lb_today, tasks_today))
make_buttons(frame_today, lb_today, tasks_today)

# Future
frame_future = tk.Frame(frame)
frame_future.grid(row=1, column=2, padx=5, pady=5)
tk.Label(frame_future, text="Future Tasks").pack()
lb_future = tk.Listbox(frame_future, width=40, height=15)
lb_future.pack()
lb_future.bind("<Double-Button-1>", lambda e: open_task(lb_future, tasks_future))
make_buttons(frame_future, lb_future, tasks_future)

refresh_listboxes()

# ---------- Save & Quit ----------
tk.Button(root, text="Save & Quit", command=lambda: (save_tasks(), root.destroy())).pack(pady=10)

root.mainloop()

'''

✅ Dashboard Features

    Buffer Tasks on the top row, full width

    Previous / Today / Future in three columns below

    Buttons attached to each listbox for Complete / Delete / Move

    Double-click to open tasks in zed

    Natural language move via system date -d

    Color-coded columns for clarity

    Auto-save back to Markdown files

This gives you a fully integrated GUI that complements your Bash script workflow perfectly.

If you want, the next step is to add scrollbars to each listbox so even huge buffers are fully navigable — the buttons stay attached.

Do you want me to add those scrollbars?
'''
