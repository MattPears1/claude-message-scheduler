; Smart Command Prompt Queue - With verification and retry
; Detects if message was sent and retries if needed

global MessageQueues := Map()
global MessageID := 0
global UserActiveThreshold := 30000  ; 30 seconds of inactivity before sending
global RetryAttempts := 3
global PauseWhenActive := false  ; Set to true to wait for inactivity

; F9 - Schedule a message with smart sending
F9:: {
    global MessageQueues, MessageID
    
    hwnd := WinGetID("A")
    title := WinGetTitle("A")
    
    ; Create input GUI
    inputGui := Gui("+AlwaysOnTop", "Smart Schedule Message")
    inputGui.MarginX := 15
    inputGui.MarginY := 15
    
    ; Window info
    inputGui.Add("Text", "Section", "Window: " . title)
    inputGui.Add("Text", "w400 h1 Background808080")
    
    ; Message input
    inputGui.Add("Text", "Section", "Message to send:")
    msgEdit := inputGui.Add("Edit", "w400 r3")
    
    ; Delay input
    inputGui.Add("Text", "Section", "When to send:")
    delayEdit := inputGui.Add("Edit", "w100")
    inputGui.Add("Text", "x+10", "Examples: 30s, 5m, 1h")
    
    ; Smart options
    inputGui.Add("Text", "xs Section", "Smart Options:")
    chkWaitInactive := inputGui.Add("CheckBox", "Checked" . PauseWhenActive, "Wait until I'm inactive to send")
    chkVerify := inputGui.Add("CheckBox", "Checked", "Verify message was sent (recommended)")
    
    ; Buttons
    btnSubmit := inputGui.Add("Button", "w80 xs Section Default", "&Submit")
    btnCancel := inputGui.Add("Button", "w80 x+10", "&Cancel")
    
    btnSubmit.OnEvent("Click", SubmitMessage)
    btnCancel.OnEvent("Click", (*) => inputGui.Destroy())
    
    SubmitMessage(*) {
        message := msgEdit.Text
        delay := delayEdit.Text
        waitInactive := chkWaitInactive.Value
        verify := chkVerify.Value
        
        if (message = "") {
            MsgBox("Please enter a message!", "Error", "Icon!")
            return
        }
        
        if (delay = "") {
            MsgBox("Please enter a delay!", "Error", "Icon!")
            return
        }
        
        delayMs := ParseDelay(delay)
        if (delayMs <= 0) {
            MsgBox("Invalid delay format!", "Error", "Icon!")
            return
        }
        
        inputGui.Destroy()
        AddSmartMessage(hwnd, title, message, delayMs, waitInactive, verify)
    }
    
    inputGui.Show()
    msgEdit.Focus()
}

; Add message with smart features
AddSmartMessage(hwnd, title, message, delayMs, waitInactive, verify) {
    global MessageQueues, MessageID
    
    if (!MessageQueues.Has(hwnd)) {
        MessageQueues[hwnd] := {
            Title: title,
            Messages: []
        }
    }
    
    MessageID++
    currentID := MessageID
    sendTime := DateAdd(A_Now, delayMs//1000, "Seconds")
    
    ; Create smart timer function
    timerFunc := () => SmartSendMessage(hwnd, currentID)
    
    msg := {
        ID: currentID,
        Text: message,
        SendTime: sendTime,
        Timer: timerFunc,
        Sent: false,
        WaitInactive: waitInactive,
        Verify: verify,
        RetryCount: 0,
        OriginalText: ""  ; Store what was in the box before
    }
    
    MessageQueues[hwnd].Messages.Push(msg)
    SetTimer(timerFunc, -delayMs)
    
    ShowNotification("Smart Message Scheduled", 
                     "Will send in " . FormatDelay(delayMs) . 
                     (waitInactive ? "`nWaiting for inactivity" : "") .
                     (verify ? "`nWith send verification" : ""))
}

; Smart send with verification and retry
SmartSendMessage(hwnd, msgID) {
    global MessageQueues, UserActiveThreshold, RetryAttempts
    
    if (!WinExist(hwnd) || !MessageQueues.Has(hwnd))
        return
    
    ; Find message
    for msg in MessageQueues[hwnd].Messages {
        if (msg.ID = msgID && !msg.Sent) {
            ; Check if we should wait for inactivity
            if (msg.WaitInactive && A_TimeIdlePhysical < UserActiveThreshold) {
                ; User is active, retry in 1 minute
                ShowNotification("Postponing Send", "User active, will retry in 1 minute")
                SetTimer(() => SmartSendMessage(hwnd, msgID), -60000)
                return
            }
            
            ; Attempt to send
            success := AttemptSend(hwnd, msg)
            
            if (success) {
                msg.Sent := true
                ShowNotification("✓ Message Sent", msg.Text)
            } else {
                ; Retry logic
                msg.RetryCount++
                if (msg.RetryCount < RetryAttempts) {
                    retryDelay := msg.RetryCount * 5000  ; 5s, 10s, 15s
                    ShowNotification("⚠️ Send Failed", "Retrying in " . (retryDelay/1000) . " seconds...")
                    SetTimer(() => SmartSendMessage(hwnd, msgID), -retryDelay)
                } else {
                    ShowNotification("❌ Send Failed", "Failed after " . RetryAttempts . " attempts")
                    msg.Sent := true  ; Mark as sent to avoid infinite retries
                }
            }
            break
        }
    }
}

; Attempt to send with verification
AttemptSend(hwnd, msg) {
    try {
        ; Store current clipboard
        oldClip := ClipboardAll()
        
        ; Activate window
        WinActivate(hwnd)
        Sleep(300)  ; Longer delay for window activation
        
        ; Get current text if verify is on
        if (msg.Verify) {
            ; Select all and copy to see what's currently there
            Send("^a")
            Sleep(100)
            Send("^c")
            Sleep(100)
            msg.OriginalText := A_Clipboard
        }
        
        ; Clear and type message
        Send("^a")
        Sleep(100)
        SendText(msg.Text)
        Sleep(200)
        
        ; Verify text was typed correctly
        if (msg.Verify) {
            Send("^a")
            Sleep(100)
            Send("^c")
            Sleep(100)
            
            typedText := A_Clipboard
            if (typedText != msg.Text) {
                ; Text didn't match, try again
                A_Clipboard := oldClip
                return false
            }
        }
        
        ; Send Enter key multiple ways for reliability
        Send("{Enter}")
        Sleep(100)
        SendEvent("{Enter}")  ; Try different send method
        
        ; Verify send worked
        if (msg.Verify) {
            Sleep(500)  ; Wait for send
            
            ; Check if input box is now empty or has different text
            Send("^a")
            Sleep(100)
            Send("^c")
            Sleep(100)
            
            currentText := A_Clipboard
            
            ; Restore clipboard
            A_Clipboard := oldClip
            
            ; If text is still there, send likely failed
            if (currentText = msg.Text) {
                return false
            }
        }
        
        ; Restore clipboard
        A_Clipboard := oldClip
        return true
        
    } catch as e {
        ShowNotification("Error", "Exception: " . e.Message)
        return false
    }
}

; Shift+F9 - View smart queue
+F9:: {
    hwnd := WinGetID("A")
    title := WinGetTitle("A")
    
    viewGui := Gui("+AlwaysOnTop", "Smart Message Queue - " . title)
    viewGui.MarginX := 15
    viewGui.MarginY := 15
    
    viewGui.Add("Text", "Section", "Scheduled Messages with Smart Features:")
    viewGui.Add("Text", "w600 h1 Background808080")
    
    lvMessages := viewGui.Add("ListView", "w700 r10", 
                             ["Message", "Send Time", "Countdown", "Options", "Status"])
    
    ; Populate
    hasMessages := false
    if (MessageQueues.Has(hwnd)) {
        for msg in MessageQueues[hwnd].Messages {
            if (!msg.Sent) {
                remaining := DateDiff(msg.SendTime, A_Now, "Seconds")
                
                if (remaining > 0) {
                    hasMessages := true
                    timeStr := FormatDelay(remaining * 1000)
                    sendTimeStr := FormatTime(msg.SendTime, "HH:mm")
                    
                    displayMsg := msg.Text
                    if (StrLen(displayMsg) > 35)
                        displayMsg := SubStr(displayMsg, 1, 32) . "..."
                    
                    options := ""
                    if (msg.WaitInactive)
                        options .= "Wait "
                    if (msg.Verify)
                        options .= "Verify"
                    
                    status := msg.RetryCount > 0 ? "Retry " . msg.RetryCount : "Waiting"
                    
                    lvMessages.Add("", displayMsg, sendTimeStr, timeStr, options, status)
                }
            }
        }
    }
    
    if (!hasMessages) {
        lvMessages.Add("", "No messages scheduled", "", "", "", "")
    }
    
    lvMessages.ModifyCol()
    
    ; Auto refresh
    RefreshTimer := () => RefreshSmartView()
    SetTimer(RefreshTimer, 1000)
    
    RefreshSmartView() {
        ; ... refresh code similar to above
    }
    
    ; Settings button
    btnSettings := viewGui.Add("Button", "w100 Section", "⚙️ Settings")
    btnSettings.OnEvent("Click", ShowSettings)
    
    btnClose := viewGui.Add("Button", "w100 x+10", "&Close")
    btnClose.OnEvent("Click", (*) => {
        SetTimer(RefreshTimer, 0)
        viewGui.Destroy()
    })
    
    viewGui.Show()
}

; Settings dialog
ShowSettings(*) {
    global UserActiveThreshold, RetryAttempts, PauseWhenActive
    
    settingsGui := Gui("+AlwaysOnTop", "Smart Scheduler Settings")
    settingsGui.MarginX := 15
    settingsGui.MarginY := 15
    
    settingsGui.Add("Text", "Section", "Inactivity Threshold (seconds):")
    thresholdEdit := settingsGui.Add("Edit", "w100", UserActiveThreshold // 1000)
    
    settingsGui.Add("Text", "Section", "Retry Attempts:")
    retryEdit := settingsGui.Add("Edit", "w100", RetryAttempts)
    
    chkPause := settingsGui.Add("CheckBox", "Section Checked" . PauseWhenActive, 
                                "Always wait for inactivity before sending")
    
    btnSave := settingsGui.Add("Button", "w80 Section", "Save")
    btnSave.OnEvent("Click", (*) => {
        UserActiveThreshold := Integer(thresholdEdit.Text) * 1000
        RetryAttempts := Integer(retryEdit.Text)
        PauseWhenActive := chkPause.Value
        
        ShowNotification("Settings Saved", "Smart scheduler settings updated")
        settingsGui.Destroy()
    })
    
    settingsGui.Show()
}

; Ctrl+F9 - Pause/Resume all schedules
^F9:: {
    global SchedulerPaused
    SchedulerPaused := !SchedulerPaused
    
    if (SchedulerPaused) {
        ShowNotification("Scheduler Paused", "All messages on hold")
    } else {
        ShowNotification("Scheduler Resumed", "Messages will send normally")
    }
}

; Helper functions
ParseDelay(input) {
    input := Trim(input)
    
    if (RegExMatch(input, "^(\d+)s$", &m))
        return Integer(m[1]) * 1000
    else if (RegExMatch(input, "^(\d+)m$", &m))
        return Integer(m[1]) * 60000
    else if (RegExMatch(input, "^(\d+)h$", &m))
        return Integer(m[1]) * 3600000
    else if (RegExMatch(input, "^\d+$"))
        return Integer(input) * 60000
    
    return 0
}

FormatDelay(ms) {
    seconds := ms // 1000
    
    if (seconds < 60)
        return seconds . " seconds"
    else if (seconds < 3600)
        return Round(seconds / 60, 1) . " minutes"
    else
        return Round(seconds / 3600, 1) . " hours"
}

ShowNotification(title, text) {
    ToolTip(title . "`n" . text)
    SetTimer(() => ToolTip(), -3000)
}

; Startup
TrayTip("Smart Scheduler Active", "F9 = Schedule | Shift+F9 = View | Ctrl+F9 = Pause", 1)