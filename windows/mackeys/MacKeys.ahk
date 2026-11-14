; ============================================================================
;  MacKeys: macOS-style keyboard + Rectangle window shortcuts for Windows
;  Keychron in WINDOWS mode. Bottom-left row is treated as:
;     [Ctrl] = Control     [Win] = Option     [Alt] = Command
;  Edit this file, then right-click the tray icon > Reload Script.
; ============================================================================
#Requires AutoHotkey v2.0
#SingleInstance Force
InstallKeybdHook()
SetWinDelay -1
SetKeyDelay -1
A_MenuMaskKey := "vkE8"
A_IconTip := "MacKeys (Mac keys + Rectangle)"
; Per-monitor DPI awareness so window math is right on mixed-DPI monitors
DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")

global cmdTabbing := false

; ---- Safety: log, kill switch, stuck-key guard -----------------------------
global LogFile := A_ScriptDir "\MacKeys.log"
Log(msg) {
    try FileAppend FormatTime(, "HH:mm:ss") "." A_MSec "  " msg "`n", LogFile
}
Log("=== started ===")

; Errors go to MacKeys.log instead of popping up windows
OnError(LogError)
LogError(e, mode) {
    Log("ERROR: " e.Message " | line " e.Line " | " e.What " | " e.Extra)
    return 1
}

; Always let go of every modifier when the script stops
OnExit(ReleaseAll)
ReleaseAll(reason, code) {
    Send "{Blind}{LCtrl up}{RCtrl up}{LAlt up}{RAlt up}{LWin up}{RWin up}{LShift up}{RShift up}"
    Log("=== exited (" reason ", code " code ") ===")
}

; KILL SWITCH: HOLD Esc for 3 seconds -> script exits, keyboard back to normal
; (Tapping Esc, even many times, does nothing special.)
~*Esc:: {
    if !KeyWait("Esc", "T3") {
        Log("kill switch")
        ExitApp
    }
}

; Every 200 ms: if Ctrl/Alt are "down" but nothing is holding them, release them
SetTimer StuckGuard, 200
StuckGuard() {
    global cmdTabbing
    if GetKeyState("RCtrl") && !Cmd() && !GetKeyState("CapsLock", "P") && !GetKeyState("RCtrl", "P") && !cmdTabbing {
        Log("stuck RCtrl released")
        Send "{Blind}{RCtrl up}"
    }
    if GetKeyState("LCtrl") && !GetKeyState("LCtrl", "P") {
        Log("stuck LCtrl released")
        Send "{Blind}{LCtrl up}"
    }
    if GetKeyState("LAlt") && !Opt() && !GetKeyState("LAlt", "P") && !cmdTabbing {
        Log("stuck LAlt released")
        Send "{Blind}{vkE8}{LAlt up}"
    }
    if cmdTabbing && !Cmd() {
        Log("stuck Cmd+Tab released")
        cmdTabbing := false
        Send "{Blind}{LAlt up}{RCtrl up}"
    }
}

; ---- Physical modifier state (what your fingers are holding) --------------
Cmd() => GetKeyState("LAlt", "P") || GetKeyState("RAlt", "P")
Opt() => GetKeyState("LWin", "P") || GetKeyState("RWin", "P")
Ctl() => GetKeyState("LCtrl", "P") || GetKeyState("RCtrl", "P") || GetKeyState("CapsLock", "P")
Shf() => GetKeyState("Shift", "P")
Mods(wantCmd, wantOpt, wantCtl) => (Cmd() ? 1 : 0) = wantCmd && (Opt() ? 1 : 0) = wantOpt && (Ctl() ? 1 : 0) = wantCtl

; ---- Base remaps -----------------------------------------------------------
; Cmd and Caps Lock both send RIGHT Ctrl. Apps treat it as normal Ctrl, but
; Willow Voice listens for LEFT Ctrl, so these keys never trigger it by accident.

; Command (Alt key) -> Ctrl, so Cmd+C/V/X/Z/A/S/T/W/F/L/R/N... all just work
*LAlt::CmdDown()
*LAlt up::CmdUp()
*RAlt::CmdDown()
*RAlt up::CmdUp()

; Caps Lock -> Control
*CapsLock::Send "{Blind}{RCtrl DownR}"
*CapsLock up::Send "{Blind}{RCtrl up}"

; The real Ctrl key is left alone: real Ctrl + Option = Willow Voice
; (Willow sees Left Ctrl + Left Alt and handles hold / double-tap itself).

; Option (Win key) -> Alt, without the Start menu or menu-bar flashing
*LWin::Send "{Blind}{LAlt DownR}"
*LWin up::Send "{Blind}{vkE8}{LAlt up}"
*RWin::Send "{Blind}{LAlt DownR}"
*RWin up::Send "{Blind}{vkE8}{LAlt up}"

CmdDown() {
    if cmdTabbing   ; ignore key auto-repeat while the app switcher is open
        return
    Send "{Blind}{RCtrl DownR}"
}

CmdUp() {
    global cmdTabbing
    if cmdTabbing {
        cmdTabbing := false
        Send "{Blind}{LAlt up}"
    }
    Send "{Blind}{RCtrl up}"
}

; Cmd+Tab -> Alt+Tab that stays open while Cmd is held (Shift = reverse)
CmdTab() {
    global cmdTabbing := true
    Send "{Blind}{RCtrl up}{LAlt down}{Tab}"
}


; ============================================================================
;  RECTANGLE  (Ctrl + Option + key)
; ============================================================================
#HotIf Mods(0, 1, 1)
*Left::Snap("left")        ; repeat to cycle 1/2 -> 2/3 -> 1/3
*Right::Snap("right")
*Up::Snap(Shf() ? "maxh" : "top")   ; +Shift = maximize height
*Down::Snap("bottom")
*u::Snap("tl")
*i::Snap("tr")
*j::Snap("bl")
*k::Snap("br")
*d::Snap("third1")
*f::Snap("third2")
*g::Snap("third3")
*e::Snap("twothirds1")
*t::Snap("twothirds2")
*Enter::Snap("max")
*c::Snap("center")
*Backspace::Snap("restore")
*=::Snap("larger")
*-::Snap("smaller")

; Ctrl + Option + Cmd + Left/Right = previous / next display
#HotIf Mods(1, 1, 1)
*Left::MoveDisplay(-1)
*Right::MoveDisplay(1)

; ============================================================================
;  CONTROL (physical Ctrl): Spaces / Mission Control
; ============================================================================
#HotIf Mods(0, 0, 1) && !Shf()
*Left::WinSend("^{Left}")    ; previous desktop
*Right::WinSend("^{Right}")  ; next desktop
*Up::WinSend("{Tab}")        ; Mission Control -> Task View
*Space::SwitchLayout()       ; switch keyboard layout (English <-> Spanish)

; Cmd + Ctrl + Shift + 3/4/5: screenshot straight to the clipboard (as on Mac)
#HotIf Mods(1, 0, 1) && Shf()
*3::WinSend("{PrintScreen}")
*4::Run("ms-screenclip:")
*5::Run("ms-screenclip:")

; Ctrl + Cmd combos
#HotIf Mods(1, 0, 1)
*q::DllCall("LockWorkStation")   ; lock screen
*f::Send "{F11}"                 ; full screen
*Space::WinSend(".")               ; emoji picker

; ============================================================================
;  COMMAND + OPTION
; ============================================================================
#HotIf Mods(1, 1, 0)
*Esc::Send "^+{Esc}"       ; Force Quit -> Task Manager
*Left::Send "^{PgUp}"      ; previous tab
*Right::Send "^{PgDn}"     ; next tab
*i::Send "^+i"             ; dev tools
*j::Send "^+j"             ; JS console

; ============================================================================
;  COMMAND
; ============================================================================
; File Explorer acts like Finder
#HotIf Mods(1, 0, 0) && !cmdTabbing && WinActive("ahk_class CabinetWClass")
*Backspace::Send "{Delete}"   ; move to Recycle Bin
*Up::Send "!{Up}"             ; parent folder
*Down::Send "{Enter}"         ; open

#HotIf Mods(1, 0, 0) && !cmdTabbing && Shf()
*3::WinSend("{PrintScreen}") ; full screenshot -> Pictures\Screenshots
*4::Run("ms-screenclip:")            ; region screenshot
*5::Run("ms-screenclip:")
*[::Send "^{PgUp}"         ; previous tab
*]::Send "^{PgDn}"         ; next tab

#HotIf Mods(1, 0, 0) && !cmdTabbing
*Tab::CmdTab()
*Space::ToggleRaycast()    ; Spotlight -> Raycast
*q::Send "!{F4}"           ; quit
*m::WinMinimize "A"
*h::WinMinimize "A"
*`::CycleAppWindows()      ; next window of the same app
*Left::Send Shf() ? "+{Home}" : "{Home}"
*Right::Send Shf() ? "+{End}" : "{End}"
*Up::Send Shf() ? "^+{Home}" : "^{Home}"
*Down::Send Shf() ? "^+{End}" : "^{End}"
*Backspace::Send "+{Home}{Backspace}"   ; delete to start of line

; ============================================================================
;  OPTION: word-wise editing
; ============================================================================
#HotIf Mods(0, 1, 0)
*Left::Send Shf() ? "^+{Left}" : "^{Left}"
*Right::Send Shf() ? "^+{Right}" : "^{Right}"
*Backspace::Send "^{Backspace}"
*Delete::Send "^{Delete}"

#HotIf

; ============================================================================
;  Window management
; ============================================================================
global snapState := Map()     ; hwnd -> {action, step, rect}
global restoreState := Map()  ; hwnd -> rect before first snap

Snap(action) {
    hwnd := WinExist("A")
    if !hwnd || IsShell(hwnd)
        return
    if WinGetMinMax(hwnd) != 0
        WinRestore hwnd
    wa := WorkArea(hwnd)
    cur := Frame(hwnd)
    aw := wa.r - wa.x, ah := wa.b - wa.y

    if action = "restore" {
        if restoreState.Has(hwnd) {
            SetFrame(hwnd, restoreState[hwnd])
            restoreState.Delete(hwnd)
        }
        if snapState.Has(hwnd)
            snapState.Delete(hwnd)
        return
    }

    prev := snapState.Has(hwnd) ? snapState[hwnd] : 0
    ours := prev && SameRect(prev.rect, cur)
    if !ours
        restoreState[hwnd] := cur
    step := (ours && prev.action = action) ? Mod(prev.step + 1, 3) : 0
    frac := [1/2, 2/3, 1/3][step + 1]

    switch action {
        case "left":       rc := {x: wa.x, y: wa.y, w: aw*frac, h: ah}
        case "right":      rc := {x: wa.r - aw*frac, y: wa.y, w: aw*frac, h: ah}
        case "top":        rc := {x: wa.x, y: wa.y, w: aw, h: ah*frac}
        case "bottom":     rc := {x: wa.x, y: wa.b - ah*frac, w: aw, h: ah*frac}
        case "tl":         rc := {x: wa.x, y: wa.y, w: aw/2, h: ah/2}
        case "tr":         rc := {x: wa.x + aw/2, y: wa.y, w: aw/2, h: ah/2}
        case "bl":         rc := {x: wa.x, y: wa.y + ah/2, w: aw/2, h: ah/2}
        case "br":         rc := {x: wa.x + aw/2, y: wa.y + ah/2, w: aw/2, h: ah/2}
        case "third1":     rc := {x: wa.x, y: wa.y, w: aw/3, h: ah}
        case "third2":     rc := {x: wa.x + aw/3, y: wa.y, w: aw/3, h: ah}
        case "third3":     rc := {x: wa.x + 2*aw/3, y: wa.y, w: aw/3, h: ah}
        case "twothirds1": rc := {x: wa.x, y: wa.y, w: 2*aw/3, h: ah}
        case "twothirds2": rc := {x: wa.x + aw/3, y: wa.y, w: 2*aw/3, h: ah}
        case "max":        rc := {x: wa.x, y: wa.y, w: aw, h: ah}
        case "maxh":       rc := {x: cur.x, y: wa.y, w: cur.w, h: ah}
        case "center":
            cw := Min(cur.w, aw), ch := Min(cur.h, ah)
            rc := {x: wa.x + (aw - cw)/2, y: wa.y + (ah - ch)/2, w: cw, h: ch}
        case "larger":
            rc := ClampRect({x: cur.x - 30, y: cur.y - 30, w: cur.w + 60, h: cur.h + 60}, wa)
        case "smaller":
            cw := Max(cur.w - 60, 300), ch := Max(cur.h - 60, 200)
            rc := {x: cur.x + (cur.w - cw)/2, y: cur.y + (cur.h - ch)/2, w: cw, h: ch}
        default:
            return
    }
    SetFrame(hwnd, RoundRect(rc))
    snapState[hwnd] := {action: action, step: step, rect: Frame(hwnd)}
}

MoveDisplay(dir) {
    hwnd := WinExist("A")
    if !hwnd || IsShell(hwnd)
        return
    n := MonitorGetCount()
    if n < 2
        return
    ; monitors sorted left -> right
    mons := []
    loop n {
        MonitorGetWorkArea A_Index, &l, &t, &r, &b
        mons.Push({x: l, y: t, r: r, b: b})
    }
    loop mons.Length - 1 {
        i := A_Index
        loop mons.Length - i {
            j := A_Index
            if mons[j].x > mons[j + 1].x {
                tmp := mons[j], mons[j] := mons[j + 1], mons[j + 1] := tmp
            }
        }
    }
    wasMax := WinGetMinMax(hwnd) = 1
    if wasMax
        WinRestore hwnd
    wa := WorkArea(hwnd)
    pos := 1
    for i, m in mons
        if m.x = wa.x && m.y = wa.y
            pos := i
    dst := mons[Mod(pos - 1 + dir + n, n) + 1]

    f := Frame(hwnd)
    sw := wa.r - wa.x, sh := wa.b - wa.y
    dw := dst.r - dst.x, dh := dst.b - dst.y
    rc := RoundRect({x: dst.x + (f.x - wa.x) * dw / sw, y: dst.y + (f.y - wa.y) * dh / sh
                   , w: f.w * dw / sw, h: f.h * dh / sh})
    SetFrame(hwnd, rc)
    SetFrame(hwnd, rc)   ; second pass in case the DPI change resized it
    if wasMax
        WinMaximize hwnd
    if snapState.Has(hwnd)
        snapState.Delete(hwnd)
}

; Windows shortcuts are sent with the RIGHT Win key: Willow Voice listens for
; Left Win + Left Shift / Left Ctrl, so these never trigger dictation.
WinSend(keys) {
    Send "{RWin down}" keys "{RWin up}"
}

; Fast path: press Raycast's own hotkey, Ctrl+Shift+Space (set that in
; Raycast Settings > General > Raycast Hotkey). Sent with RIGHT-side modifiers
; so Willow Voice never sees it.
; Fallback: if Raycast doesn't appear within 150 ms, open the raycast:// link
; (slower, ~0.5 s). Pressing Cmd+Space again while it's open closes it.
ToggleRaycast() {
    if RaycastVisible() {
        Send "{Esc}"
        return
    }
    t0 := A_TickCount
    Send "{Blind}{RCtrl down}{RShift down}{Space}{RShift up}"
    if !Cmd()
        Send "{Blind}{RCtrl up}"
    while A_TickCount - t0 < 300 {
        if RaycastVisible() {
            Log("raycast hotkey " (A_TickCount - t0) " ms")
            return
        }
        Sleep 5
    }
    Log("raycast hotkey failed, using raycast:// link")
    try Run "raycast://"
}

RaycastVisible() {
    for h in WinGetList("ahk_exe Raycast.exe") {
        WinGetPos , , &w, &h2, h
        if w > 200 && h2 > 100 && WinGetTitle(h) != "Raycast Settings"
            return true
    }
    return false
}

; Caps+Space: switch to the next keyboard layout (English <-> Spanish).
; Asks the focused window directly instead of pressing Win+Space, so it
; can't collide with Raycast, Willow or the Start menu.
SwitchLayout() {
    hwnd := WinExist("A")
    if !hwnd
        return
    try focus := ControlGetFocus(hwnd)
    target := (IsSet(focus) && focus) ? focus : hwnd
    PostMessage 0x50, 2, 0, , target   ; WM_INPUTLANGCHANGEREQUEST, next layout
}

; Test hook: lets a helper script trigger these without physical keys
OnMessage(0x8001, (wp, *) => (wp = 1 ? ToggleRaycast() : SwitchLayout(), 0))

CycleAppWindows() {
    try exe := WinGetProcessName("A")
    catch
        return
    wins := []
    for hwnd in WinGetList("ahk_exe " exe) {
        if WinGetTitle(hwnd) = "" || IsShell(hwnd)
            continue
        if !(WinGetStyle(hwnd) & 0x10000000) || (WinGetExStyle(hwnd) & 0x80)
            continue
        wins.Push(hwnd)
    }
    if wins.Length > 1
        WinActivate wins[wins.Length]
}

; ---- helpers ---------------------------------------------------------------
IsShell(hwnd) {
    try cls := WinGetClass(hwnd)
    catch
        return true
    return cls ~= "^(Progman|WorkerW|Shell_TrayWnd|Shell_SecondaryTrayWnd)$"
}

WorkArea(hwnd) {
    hMon := DllCall("MonitorFromWindow", "ptr", hwnd, "uint", 2, "ptr")
    mi := Buffer(40, 0)
    NumPut("uint", 40, mi)
    DllCall("GetMonitorInfo", "ptr", hMon, "ptr", mi)
    return {x: NumGet(mi, 20, "int"), y: NumGet(mi, 24, "int")
          , r: NumGet(mi, 28, "int"), b: NumGet(mi, 32, "int")}
}

; Visible frame (excludes Windows 10/11 invisible resize borders)
Frame(hwnd) {
    rect := Buffer(16, 0)
    if DllCall("dwmapi\DwmGetWindowAttribute", "ptr", hwnd, "uint", 9, "ptr", rect, "uint", 16) = 0 {
        l := NumGet(rect, 0, "int"), t := NumGet(rect, 4, "int")
        return {x: l, y: t, w: NumGet(rect, 8, "int") - l, h: NumGet(rect, 12, "int") - t}
    }
    WinGetPos &x, &y, &w, &h, hwnd
    return {x: x, y: y, w: w, h: h}
}

SetFrame(hwnd, rc) {
    WinGetPos &wx, &wy, &ww, &wh, hwnd
    f := Frame(hwnd)
    bl := f.x - wx, bt := f.y - wy
    br := (wx + ww) - (f.x + f.w), bb := (wy + wh) - (f.y + f.h)
    WinMove rc.x - bl, rc.y - bt, rc.w + bl + br, rc.h + bt + bb, hwnd
}

RoundRect(rc) => {x: Round(rc.x), y: Round(rc.y), w: Round(rc.w), h: Round(rc.h)}

ClampRect(rc, wa) {
    x := Max(rc.x, wa.x), y := Max(rc.y, wa.y)
    return {x: x, y: y, w: Min(rc.x + rc.w, wa.r) - x, h: Min(rc.y + rc.h, wa.b) - y}
}

SameRect(a, b) => Abs(a.x - b.x) <= 2 && Abs(a.y - b.y) <= 2 && Abs(a.w - b.w) <= 2 && Abs(a.h - b.h) <= 2
