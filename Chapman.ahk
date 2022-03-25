; 2.0-a136-feda41f4

#Include <class\WindowHandler>
#Include modules\CheatEngine.ahk

#Warn VarUnset, Off
#SingleInstance Force
Persistent True

InstallKeybdHook ; This seems to let CE catch the hotkeys

; -------------------------------------------------------------------------------------------------------------------------------

#Include <class\Troy>

g_ti := Troy("C:\Users\ihate\Dropbox\AHK\ico\HYDRATTZ\")
g_ti.SetIcon("C")

; -------------------------------------------------------------------------------------------------------------------------------

if (!A_IsAdmin) {
    try {
        Run Format('*RunAs "{}" /restart "{}"', A_AhkPath, A_ScriptFullPath)
    }

    ExitApp
}

; -------------------------------------------------------------------------------------------------------------------------------

; Small tools to help make using Cheat Engine a little nicer.
; Named after Stephen Chapman - https://www.youtube.com/c/StephenChapman/videos

; -------------------------------------------------------------------------------------------------------------------------------

class Chapman extends WindowHandler {
    __new() {
        super.__new()

        this.SetWinTitle("A") ; The focused window
        this.ce := CheatEngine()
    }

    CheatFocusedWindow() {
        local id := "ahk_id " . this.GetID() ; Only the HWND that GetID is required
        this.SetWinTitle(id)

        this.__WaitForModifiers()

        BlockInput True
        ; BlockInput "On"

        if not this.ce.Exists() {
            ; The main CE window is spawned by a sub-process so our internal wait in Run() is useless
            this.ce.Run()

            ; For the same reasons as above we can't explicitly call WaitActivate() here either
            Sleep 2500

            ; CE has the issue of showing up on the wrong taskbar if it's last known position wasn't the primary monitor
            ; WinMinimize and WinRestore don't fix it
            ; Manually minimizing with AHK causes an issue that requires 3-4 clicks to restore the window from the taskbar
            PostMessage 0x112, 0xF020,,, this.ce.GetWinTitle() ; 0x112 = WM_SYSCOMMAND, 0xF020 = SC_MINIMIZE
            Sleep 500
            PostMessage 0x112, 0xF120,,, this.ce.GetWinTitle()  ; 0x112 = WM_SYSCOMMAND, 0xF120 = SC_RESTORE
            Sleep 500
        } else {
            ; Sometimes CE has hidden windows that prevent you from opening a new instance, bring them to the front
            this.ce.Activate()
        }

        this.Activate()
        this.WaitActive()

        ; TODO Very poor reliability, need to look into another method of forcing and detecting the hook with AHK
        ; The Send just doesn't actually work all the time, it depends on a lot of different factors. Executable, administrator status, or otherwise.
        Send this.ce.InternalHotKeys.Attach ; CE shortcut, should hook the focused window, not CE

        BlockInput False
        ; BlockInput "Off"

        this.SetWinTitle("A")
    }
}

g_Chapman := Chapman()

; -------------------------------------------------------------------------------------------------------------------------------

; This script needs to be elevated for the hotkeys to reach CE

; OS Global
g_Chapman.SetHotKey("#Pause", "CheatFocusedWindow")

; CE Global
g_Chapman.ce.SetHotKey("+CapsLock", "__HotKey_ArrowHelper")
g_Chapman.ce.SetHotKey("^Backspace", "__HotKey_DeleteWord")

; Memory Viewer
g_Chapman.ce.SetHotKey("``",  "__HotKey_MemoryViewer_CycleDisplayType", 32) ; ` needs to be escaped with itself in AHK
g_Chapman.ce.SetHotKey("^``", "__HotKey_MemoryViewer_CycleDisplayType", 64) ; ` needs to be escaped with itself in AHK
g_Chapman.ce.SetHotKey("^,", "__HotKey_MemoryViewer_OpenPreferences")
g_Chapman.ce.SetHotKey("^,", "__HotKey_MemoryViewer_OpenPreferences")
g_Chapman.ce.SetHotKey("XButton1", "__HotKey_MemoryViewer_Back")

; Code List/Advanced Options
g_Chapman.ce.SetHotKey("#F1", "__HotKey_AdvancedOptions_RenameEntry")

; Main Window/Address List/Scan
g_Chapman.ce.SetHotKey("+!Up",   "__HotKey_MainWindow_DuplicateCheatEntry", -4) ; Shift + Alt + Up
g_Chapman.ce.SetHotKey("+!Down", "__HotKey_MainWindow_DuplicateCheatEntry", 4)  ; Shift + Alt + Down
