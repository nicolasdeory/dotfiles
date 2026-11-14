# Notes: how I like to work, and what I learned wiring it up

A running list. Add a line whenever a shortcut or habit sticks, or a gotcha bites.

## Ways of working

- Mac muscle memory everywhere: Cmd for app shortcuts, Option for words, Control for system stuff.
- Window tiling from the keyboard, Rectangle-style (Control + Option + arrows/letters).
- Launcher on Cmd+Space: Raycast.
- Dictation on Control + Option (Willow Voice).
- Two keyboard layouts, English (US) and Spanish (Spain), switched with Control + Space.

## Gotchas (Windows)

- **Willow Voice grabs left-side modifier combos**: Left Ctrl + Left Alt, Left Ctrl + Left Win,
  Left Win + Left Shift. So the script sends **right-side** Ctrl/Win for everything it fakes
  (Cmd and Caps Lock become *Right* Ctrl). Real left Ctrl + Option is left untouched so Willow
  handles hold-to-talk and double-tap-to-lock itself. Faking Willow's shortcut from the script
  caused a double press, which Willow read as "lock".
- **Raycast** can't be opened fast by the `raycast://` link (~500 ms). Its own hotkey
  (Ctrl+Shift+Space) opens it in ~15 ms, so Cmd+Space presses that. Raycast's
  "Replace Start Menu" option swallows Win-key shortcuts, so the script avoids the Win key
  where it can: layout switching asks the window directly, region screenshots open
  `ms-screenclip:`.
- **Don't run two key remappers** (e.g. PowerToys Keyboard Manager + AutoHotkey). They fight
  and modifiers get stuck. Everything lives in MacKeys.ahk.
- **AutoHotkey names are case-insensitive**: a parameter named `cmd` hid the function `Cmd()`
  and broke every keypress. Watch for that when editing.
- **Kill switch must be hard to hit by accident.** "Esc three times" fired when closing
  Raycast repeatedly; now it's "hold Esc 3 s".
- **Sleep stopped the script**, and a Startup-folder shortcut didn't always relaunch it. A
  scheduled task (at login + every minute, ignore if already running) keeps it alive.
- Starting the script from inside another app (e.g. a terminal Claude runs) ties it to that
  app's lifetime. Start it through the task or Explorer.
