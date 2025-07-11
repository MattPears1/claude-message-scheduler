; Command Prompt Message Queue - Designed for CMD windows
; F9 = Schedule what you've already typed
; Shift+F9 = View queue

; Ensure only one instance runs
#SingleInstance Force

global MessageQueues := Map()
global MessageID := 0

; F9 - Schedule a message
F9:: {
    global MessageQueues, MessageID
    
    ; Get current window
    hwnd := WinGetID("A")
    title := WinGetTitle("A")
    
    ; Create custom GUI for input
    inputGui := Gui("+AlwaysOnTop", "Schedule Message")
    inputGui.MarginX := 15
    inputGui.MarginY := 15
    
    ; Window title
    inputGui.Add("Text", "Section", "Window: " . title)
    inputGui.Add("Text", "w400 h1 Background808080")  ; Separator
    
    ; Message input
    inputGui.Add("Text", "Section", "Message to send:")
    msgEdit := inputGui.Add("Edit", "w400 r3")
    
    ; Delay input
    inputGui.Add("Text", "Section", "When to send:")
    delayEdit := inputGui.Add("Edit", "w100")
    inputGui.Add("Text", "x+10", "Examples: 30s, 5m, 1h")
    
    ; Buttons
    btnSubmit := inputGui.Add("Button", "w80 xs Section Default", "&Submit")
    btnCancel := inputGui.Add("Button", "w80 x+10", "&Cancel")
    
    ; Handle submit
    btnSubmit.OnEvent("Click", SubmitMessage)
    btnCancel.OnEvent("Click", (*) => inputGui.Destroy())
    
    SubmitMessage(*) {
        message := msgEdit.Text
        delay := delayEdit.Text
        
        if (message = "") {
            MsgBox("Please enter a message!", "Error", "Icon!")
            return
        }
        
        if (delay = "") {
            MsgBox("Please enter a delay!", "Error", "Icon!")
            return
        }
        
        ; Parse delay
        delayMs := ParseDelay(delay)
        if (delayMs <= 0) {
            MsgBox("Invalid delay format! Use: 30s, 5m, 1h", "Error", "Icon!")
            return
        }
        
        ; Close dialog
        inputGui.Destroy()
        
        ; Add to queue
        AddMessageToQueue(hwnd, title, message, delayMs)
    }
    
    ; Show GUI
    inputGui.Show()
    msgEdit.Focus()
}

; Add message to queue function
AddMessageToQueue(hwnd, title, message, delayMs) {
    global MessageQueues, MessageID
    ; Initialize queue if needed
    if (!MessageQueues.Has(hwnd)) {
        MessageQueues[hwnd] := {
            Title: title,
            Messages: []
        }
    }
    
    ; Create message entry
    MessageID++
    currentID := MessageID  ; Capture current ID for closure
    sendTime := DateAdd(A_Now, delayMs//1000, "Seconds")
    
    ; Create timer function for this specific message
    timerFunc := () => SendSpecificMessage(hwnd, currentID)
    
    msg := {
        ID: currentID,
        Text: message,  ; Store the actual message text
        SendTime: sendTime,
        Timer: timerFunc,
        Sent: false
    }
    
    ; Add to queue
    MessageQueues[hwnd].Messages.Push(msg)
    
    ; Set timer
    SetTimer(timerFunc, -delayMs)
    
    ; Show confirmation
    timeStr := FormatDelay(delayMs)
    sendTimeStr := FormatTime(sendTime, "HH:mm")
    
    ToolTip("✓ Message scheduled!`n`nSends at: " . sendTimeStr . " (" . timeStr . ")`n`n" .
            "DO NOT press Enter - it will send automatically`n" .
            "Press Shift+F9 to view all scheduled")
    SetTimer(() => ToolTip(), -4000)
}

; Send a specific message
SendSpecificMessage(hwnd, msgID) {
    global MessageQueues
    
    if (!WinExist(hwnd) || !MessageQueues.Has(hwnd))
        return
    
    ; Find the specific message
    for msg in MessageQueues[hwnd].Messages {
        if (msg.ID = msgID && !msg.Sent) {
            try {
                ; Activate window
                WinActivate(hwnd)
                Sleep(200)
                
                ; Clear input and type the message
                Send("^a")  ; Select all
                Sleep(50)
                SendText(msg.Text)
                Sleep(100)
                
                ; Send Enter - try multiple methods for reliability
                Send("{Enter}")
                Sleep(50)
                SendEvent("{Enter}")
                Sleep(50)
                ControlSend("{Enter}", , hwnd)
                
                ; Mark as sent
                msg.Sent := true
                
                ToolTip("✓ Sent: " . msg.Text . "`nTo: " . MessageQueues[hwnd].Title)
                SetTimer(() => ToolTip(), -3000)
            } catch {
                ToolTip("✗ Failed to send message", , , 3)
                SetTimer(() => ToolTip(), -3000)
            }
            break
        }
    }
}

; Shift+F9 - View queue
+F9:: {
    hwnd := WinGetID("A")
    title := WinGetTitle("A")
    
    ; Create view GUI
    viewGui := Gui("+AlwaysOnTop", "Message Queue - " . title)
    viewGui.MarginX := 15
    viewGui.MarginY := 15
    
    ; Title
    viewGui.Add("Text", "Section", "Scheduled Messages for this window:")
    viewGui.Add("Text", "w500 h1 Background808080")
    
    ; Message list
    lvMessages := viewGui.Add("ListView", "w700 r10", ["#", "Message", "Send Time", "Countdown", "Status"])
    
    ; Populate list
    hasMessages := false
    count := 0
    if (MessageQueues.Has(hwnd)) {
        for msg in MessageQueues[hwnd].Messages {
            if (!msg.Sent) {
                remaining := DateDiff(msg.SendTime, A_Now, "Seconds")
                
                if (remaining > 0) {
                    count++
                    hasMessages := true
                    timeStr := FormatDelay(remaining * 1000)
                    sendTimeStr := FormatTime(msg.SendTime, "HH:mm")
                    
                    ; Truncate message for display
                    displayText := msg.Text
                    if (StrLen(displayText) > 40)
                        displayText := SubStr(displayText, 1, 37) . "..."
                    
                    lvMessages.Add("", count, displayText, sendTimeStr, timeStr, "Waiting")
                }
            }
        }
    }
    
    if (!hasMessages) {
        lvMessages.Add("", "No messages scheduled", "", "", "")
    }
    
    ; Auto-size columns
    lvMessages.ModifyCol()
    
    ; Refresh timer
    RefreshTimer := () => RefreshView()
    SetTimer(RefreshTimer, 1000)
    
    RefreshView() {
        lvMessages.Delete()
        hasMessages := false
        count := 0
        
        ; Rebuild ViewMessages array
        ViewMessages := []
        
        if (MessageQueues.Has(hwnd)) {
            for msg in MessageQueues[hwnd].Messages {
                if (!msg.Sent) {
                    remaining := DateDiff(msg.SendTime, A_Now, "Seconds")
                    
                    if (remaining > 0) {
                        hasMessages := true
                        timeStr := FormatDelay(remaining * 1000)
                        sendTimeStr := FormatTime(msg.SendTime, "HH:mm")
                        
                        ; Highlight if sending soon
                        status := remaining < 10 ? "SENDING SOON!" : "Waiting"
                        
                        ; Truncate message for display
                        displayText := msg.Text
                        if (StrLen(displayText) > 40)
                            displayText := SubStr(displayText, 1, 37) . "..."
                        
                        ; Add count for row number
                        count++
                        
                        ; Add to ViewMessages for copy/cancel
                        ViewMessages.Push({Text: msg.Text, ID: msg.ID, Timer: msg.Timer})
                        
                        lvMessages.Add("", count, displayText, sendTimeStr, timeStr, status)
                    }
                }
            }
        }
        
        if (!hasMessages) {
            lvMessages.Add("", "", "No messages scheduled", "", "", "")
        }
    }
    
    ; Store full messages for copy function
    global ViewMessages := []
    global ViewMessageRows := Map()
    rowNum := 0
    
    if (MessageQueues.Has(hwnd)) {
        for msg in MessageQueues[hwnd].Messages {
            if (!msg.Sent) {
                remaining := DateDiff(msg.SendTime, A_Now, "Seconds")
                if (remaining > 0) {
                    rowNum++
                    ViewMessages.Push({Text: msg.Text, ID: msg.ID, Timer: msg.Timer})
                    ViewMessageRows[rowNum] := msg.ID
                }
            }
        }
    }
    
    ; Buttons
    btnCopy := viewGui.Add("Button", "w80 Section", "📋 Copy")
    btnCancel := viewGui.Add("Button", "w80 x+5", "❌ Cancel")
    btnClear := viewGui.Add("Button", "w80 x+5", "Clear All")
    btnClose := viewGui.Add("Button", "w80 x+5", "&Close")
    
    ; Add instructions
    viewGui.Add("Text", "xs w400", "Select a message and click Copy to clipboard or Cancel to remove")
    
    ; Copy button handler
    btnCopy.OnEvent("Click", CopySelectedMessage)
    
    CopySelectedMessage(*) {
        selected := lvMessages.GetNext()
        if (selected > 0 && selected <= ViewMessages.Length) {
            A_Clipboard := ViewMessages[selected].Text
            ToolTip("✓ Message copied to clipboard!`n`n" . ViewMessages[selected].Text)
            SetTimer(() => ToolTip(), -2500)
        } else {
            ToolTip("Please select a message to copy")
            SetTimer(() => ToolTip(), -1500)
        }
    }
    
    ; Cancel button handler
    btnCancel.OnEvent("Click", CancelSelectedMessage)
    
    CancelSelectedMessage(*) {
        selected := lvMessages.GetNext()
        if (selected > 0 && selected <= ViewMessages.Length) {
            msgToCancel := ViewMessages[selected]
            
            ; Cancel the timer
            if (msgToCancel.Timer) {
                SetTimer(msgToCancel.Timer, 0)
            }
            
            ; Find and mark as sent
            for msg in MessageQueues[hwnd].Messages {
                if (msg.ID = msgToCancel.ID && !msg.Sent) {
                    msg.Sent := true
                    ToolTip("✓ Message cancelled`n`n" . SubStr(msg.Text, 1, 50) . "...")
                    SetTimer(() => ToolTip(), -2000)
                    
                    ; Remove from view arrays
                    ViewMessages.RemoveAt(selected)
                    
                    ; Refresh the list
                    RefreshView()
                    break
                }
            }
        } else {
            ToolTip("Please select a message to cancel")
            SetTimer(() => ToolTip(), -1500)
        }
    }
    
    btnClear.OnEvent("Click", ClearMessages)
    
    ClearMessages(*) {
        if (MessageQueues.Has(hwnd)) {
            for msg in MessageQueues[hwnd].Messages {
                if (!msg.Sent && msg.Timer) {
                    SetTimer(msg.Timer, 0)
                }
            }
            MessageQueues.Delete(hwnd)
            RefreshView()
            ToolTip("All messages cleared!")
            SetTimer(() => ToolTip(), -2000)
        }
    }
    
    btnClose.OnEvent("Click", CloseWindow)
    
    CloseWindow(*) {
        SetTimer(RefreshTimer, 0)
        viewGui.Destroy()
    }
    
    ; Show GUI
    viewGui.Show()
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

; Startup
ToolTip("Command Prompt Queue Ready!`n`n1. Type your message`n2. Press F9 to schedule`n3. It sends automatically!")
SetTimer(() => ToolTip(), -5000)