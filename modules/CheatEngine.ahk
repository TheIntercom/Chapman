; 2.0-a136-feda41f4

#include <class\WindowHandler>
; #include ..\XML.ahk

class CheatEngine extends WindowHandler {
    __new() {
        super.__new()

        this.SetWinTitle("ahk_exe cheatengine-x86_64-SSE4-AVX2.exe") ; looks sus

        this.SetExecutablePath("C:\Program Files\Cheat Engine 7.2\Cheat Engine.exe")

        this.InternalHotkeys := CheatEngine.InternalHotkeys()
        this.MemoryViewer := CheatEngine.MemoryViewer()
        this.AdvancedOptions := CheatEngine.AdvancedOptions()
        this.MainWindow := CheatEngine.MainWindow()
    }

    ; ---------- Overloads ----------

    ; ---------- Helper functions ----------

    ; ---------- Sub-classes ----------

    class InternalHotkeys {
        ; Static for now, formatted for 'Send()', not 'HotKey()'

        ; These values are stored in: HKEY_CURRENT_USER\SOFTWARE\Cheat Engine\
        Attach         := "#{Insert}" ; Attach to foregroundprocess Hotkey
        Type4Byte      := "{Numpad4}" ; 4 Bytes Hotkey
        TypeFloat      := "{Numpad5}" ; Float Hotkey
        NewScan        := "{Numpad1}" ; New Scan Hotkey
        NewScanUnknown := "{Numpad2}" ; Unknown Initial Value Hotkey
        NextIncreased  := "{NumpadAdd}" ; Increased Value Hotkey
        NextDecreased  := "{NumpadSub}" ; Decreased Value Hotkey
        NextChanged    := "{Numpad0}" ; Changed Value Hotkey
        NextUnchanged  := "{NumpadDot}" ; Unchanged Value Hotkey
        UndoLast       := "{Numpad7}" ; Undo Last scan Hotkey
        CancelScan     := "{Numpad8}" ; Cancel scan Hotkey
    }

    class MemoryViewer extends WindowHandler {
        ; ClassNN := "Window6" ; DisassemblerView
        ; ClassNN := "Window3" ; HexadecimalView

        __new() {
            super.__new()

            this.SetWinTitle("Memory Viewer")

            this.DisplayType32 := 2
            this.DisplayType64 := 2

            this._ClassNN := "Window3" ; HexadecimalView
        }
    }

    class AdvancedOptions extends WindowHandler {
        __new() {
            super.__new()

            this.SetWinTitle("Code list/Pause")
        }
    }

    class MainWindow extends WindowHandler {
        __new() {
            super.__new()

            this.SetWinTitle("Cheat Engine 7.2")
        }
    }

    ; ---------- HotKey functions ----------

    __HotKey_ArrowHelper() {
        Send " -> "

        this.__WaitForModifiers()
    }

    __HotKey_DeleteWord() {
        Send "^+{Left}"
        Send "{Backspace}"

        this.__WaitForModifiers()
    }

    __HotKey_AdvancedOptions_RenameEntry() {
        if this.AdvancedOptions.Active() {
            this.__WaitForModifiers()

            Send "^{Enter}"
            Send "{Home}"
            Send "^+{Right}"
            Send A_ClipBoard
            Send "{Enter}"

            Sleep 350

            Send "{Down}"

            this.__WaitForModifiers()
        }
    }

    __HotKey_MainWindow_DuplicateCheatEntry(d) {
        this.__WaitForModifiers()

        A_Clipboard := ""
        Send "^c"
        ClipWait

        local x := ComObject("MSXML2.DOMDocument.6.0")
        x.async := false
        x.loadXML(A_Clipboard)

        local regex_match := ""
        local address_pattern := "\+([0-9A-F]+)$" ; Expects an address similar to this format: [game.exe]+0FF537 or ABCD1234+0FF537

        ; For my tables the last child is always address
        local cte_address := x.selectSingleNode("/CheatTable/CheatEntries/CheatEntry").lastChild
        local cte_base_address_length := RegexMatch(cte_address.text, address_pattern, &regex_match) ; Doesn't capture the '+'

        ; If address length is 0 then the pattern wasn't found
        if (cte_base_address_length) {
            base_address := SubStr(cte_address.text, 1, cte_base_address_length)
            offset_original := Format("0x{}", regex_match.Count ? regex_match[1] : 0) ; Hex2UsableHex
            offset_delta := Format("0x{:X}", d) ; Dec2Hex

            output_address := Format("{}{:X}", base_address, offset_original + offset_delta) ; Standard CE format

            cte_address.text := output_address ; Directly change the XML text

            A_Clipboard := x.xml ; Put it back in the clipboard

            if (offset_delta < 0) {
                Send "{Up}"
            }
        }


        Send "^v"
        Send "{Down}"
    }

    __HotKey_MemoryViewer_CycleDisplayType(s) {
        if this.MemoryViewer.Active() {
            ; BUG The Memory Viewer window doesn't seem to like ControlSend so I have to manually focus controls

            ; BUG If we last used 'Byte hex' then we need to double tap
            ; I guess I can just store the DisplayType value in an ini somewhere
            ; But I feel like it should be stored in the registry like all the other settings

            FocusedClassNN := ControlGetClassNN(ControlGetFocus())
            if (FocusedClassNN != this.MemoryViewer._ClassNN) {
                ControlFocus(this.MemoryViewer._ClassNN, this.MemoryViewer.GetWinTitle())
            }

            if (s == 32) {
                Switch this.MemoryViewer.DisplayType32 {
                    Case 1: ; Byte hex
                        Send "^1"
                        this.MemoryViewer.DisplayType32 := 2
                    Case 2: ; 4 Byte hex
                        Send "^5"
                        this.MemoryViewer.DisplayType32 := 3
                    Case 3: ; Float
                        Send "^9"
                        this.MemoryViewer.DisplayType32 := 1
                }
            }

            if (s == 64) {
                Switch this.MemoryViewer.DisplayType64 {
                    Case 1: ; 8 Byte hex
                        Send "^7"
                        this.MemoryViewer.DisplayType64 := 2
                    Case 2: ; Double
                        Send "^0"
                        this.MemoryViewer.DisplayType64 := 1
                }
            }

            Sleep 100 ; Critical for some reason

            ControlFocus(FocusedClassNN, this.MemoryViewer.GetWinTitle())
        }
    }

    __HotKey_MemoryViewer_OpenPreferences() {
        if this.MemoryViewer.Active() {
            this.__WaitForModifiers()

            Send "{Escape}"
            Send "!v"`
            Send "p"
        }
    }

    __HotKey_MemoryViewer_Back() {
        if this.MemoryViewer.Active() {
            this.__WaitForModifiers()

            Send "{Backspace}"
        }
    }
}
