# Windows: make it feel like my Mac

An AutoHotkey script (`mackeys/MacKeys.ahk`) that gives Windows macOS-style
modifier keys plus Rectangle's window shortcuts, and opens Raycast with Cmd+Space.

## Install on a new PC

```powershell
git clone https://github.com/nicolasdeory/dotfiles $HOME\dotfiles
powershell -ExecutionPolicy Bypass -File $HOME\dotfiles\windows\install.ps1
```

The script installs AutoHotkey and Raycast and registers a scheduled task named
`MacKeys`. The task starts the script at login and relaunches it within a minute
if it ever stops; sleep used to kill it. The installer then lists a few settings
to change by hand.

## Keys

Keyboard: Keychron in **Windows** mode. The bottom-left row maps like a Mac:

| Physical key | Acts as |
| --- | --- |
| Alt (next to Space) | **Cmd** |
| Win | **Option** |
| Caps Lock | **Control** (for every Control shortcut below) |
| Ctrl (bottom-left) | Plain Ctrl. With Option it starts Willow Voice dictation |

### Command

| Shortcut | Does |
| --- | --- |
| Cmd + C / V / X / Z / A / S / T / W / F / L / N … | Copy, paste, etc. (sent as Ctrl) |
| Cmd + Tab (Shift = back) | App switcher, stays open while Cmd is held |
| Cmd + Space | Raycast (press again to close) |
| Cmd + Q | Quit (Alt+F4). Does nothing in games (Steam/Epic/etc. folders, or any full-screen app except browsers) |
| Cmd + M / H | Minimize |
| Cmd + ` | Next window of the same app |
| Cmd + ← / → (+Shift) | Start / end of line |
| Cmd + ↑ / ↓ (+Shift) | Top / bottom of document |
| Cmd + Backspace | Delete to start of line |
| Cmd + Shift + [ / ] | Previous / next tab |
| Cmd + Shift + 3 | Full screenshot to Pictures\Screenshots |
| Cmd + Shift + 4 / 5 | Region screenshot (also with Control added) |
| In Explorer: Cmd + Backspace / ↑ / ↓ | Delete / parent folder / open |

### Option

| Shortcut | Does |
| --- | --- |
| Option + ← / → (+Shift) | Jump / select by word |
| Option + Backspace / Delete | Delete word |

### Control (Caps Lock)

| Shortcut | Does |
| --- | --- |
| Control + Space | Switch keyboard layout (English ↔ Spanish) |
| Control + ← / → | Previous / next virtual desktop |
| Control + ↑ | Task View (Mission Control) |
| Control + Cmd + Q | Lock screen |
| Control + Cmd + F | Full screen (F11) |
| Control + Cmd + Space | Emoji picker |

### Cmd + Option

| Shortcut | Does |
| --- | --- |
| Cmd + Option + Esc | Task Manager (Force Quit) |
| Cmd + Option + ← / → | Previous / next tab |
| Cmd + Option + I / J | Dev tools / console |

### Rectangle (Control + Option + key)

| Key | Window goes to |
| --- | --- |
| ← → ↑ ↓ | Half. Press again to cycle ½ → ⅔ → ⅓ |
| Shift + ↑ | Maximize height |
| U I J K | Top-left, top-right, bottom-left, bottom-right quarter |
| D F G | First, center, last third |
| E T | First, last two-thirds |
| Enter | Fill the screen |
| C | Center |
| = / - | Larger / smaller |
| Backspace | Restore to size before snapping |
| + Cmd, ← / → | Previous / next monitor |

## When something's off

- **Turn it off:** hold **Esc for 3 seconds**, or use the tray icon (green H) > Suspend / Exit.
  The task brings it back within a minute; to keep it off, disable the `MacKeys` task in Task Scheduler.
- **Log:** `mackeys/MacKeys.log` records starts, exits (with the reason), errors and Raycast timing.
- **Edit:** change `MacKeys.ahk`, then tray icon > Reload Script.
- Shortcuts don't reach apps running as administrator (Task Manager, etc.). That's a Windows limit.

See [notes.md](notes.md) for why things are wired the way they are.
