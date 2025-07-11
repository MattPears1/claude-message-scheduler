; Clean Queue Scheduler - F9 to add, Shift+F9 to view
; Works with command prompt input boxes

global MessageQueues := Map()
global MessageID := 0

; F9 - Open message input dialog
F9:: {
    ; Get current window info
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
    inputGui.Add("Text", "Section", "Message:")
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
        
        ; Add to queue
        AddMessageToQueue(hwnd, title, message, delayMs)
        
        ; Close dialog
        inputGui.Destroy()
    }
    
    ; Show GUI
    inputGui.Show()
    msgEdit.Focus()
}

; Shift+F9 - View queue for current window
+F9:: {
    hwnd := WinGetID("A")
    title := WinGetTitle("A")
    
    ; Create view GUI
    viewGui := Gui("+AlwaysOnTop +Resize", "Message Queue - " . title)
    viewGui.MarginX := 15
    viewGui.MarginY := 15
    
    ; Title
    viewGui.Add("Text", "Section", "Scheduled Messages:")
    viewGui.Add("Text", "w500 h1 Background808080")  ; Separator
    
    ; Message list
    lvMessages := viewGui.Add("ListView", "w600 r10", ["#", "Message", "Send Time", "Sends In", "Status"])
    
    ; Populate list
    hasMessages := false
    if (MessageQueues.Has(hwnd)) {
        queue := MessageQueues[hwnd]
        count := 0
        
        for msg in queue.Messages {
            if (!msg.Sent) {
                remaining := DateDiff(msg.SendTime, A_Now, "Seconds")
                
                if (remaining > 0) {
                    count++
                    hasMessages := true
                    timeStr := FormatDelay(remaining * 1000)
                    ; Format absolute time
                    sendTimeStr := FormatTime(msg.SendTime, "HH:mm")
                    ; Truncate long messages
                    displayMsg := msg.Text
                    if (StrLen(displayMsg) > 40)
                        displayMsg := SubStr(displayMsg, 1, 37) . "..."
                    
                    lvMessages.Add("", count, displayMsg, sendTimeStr, timeStr, "Pending")
                }
            }
        }
    }
    
    if (!hasMessages) {
        lvMessages.Add("", "", "No messages scheduled", "", "", "")
    }
    
    ; Auto-size columns
    lvMessages.ModifyCol()
    
    ; Buttons
    btnRefresh := viewGui.Add("Button", "w80 Section", "&Refresh")
    btnClearAll := viewGui.Add("Button", "w80 x+10", "&Clear All")
    btnClose := viewGui.Add("Button", "w80 x+10", "C&lose")
    
    btnRefresh.OnEvent("Click", (*) => RefreshList())
    btnClearAll.OnEvent("Click", (*) => ClearQueue(hwnd))
    btnClose.OnEvent("Click", (*) => viewGui.Destroy())
    
    RefreshList() {
        ; Refresh the list view
        lvMessages.Delete()
        
        if (MessageQueues.Has(hwnd)) {
            queue := MessageQueues[hwnd]
            count := 0
            
            for msg in queue.Messages {
                if (!msg.Sent) {
                    count++
                    remaining := DateDiff(msg.SendTime, A_Now, "Seconds")
                    
                    if (remaining > 0) {
                        timeStr := FormatDelay(remaining * 1000)
                        sendTimeStr := FormatTime(msg.SendTime, "HH:mm")
                        displayMsg := msg.Text
                        if (StrLen(displayMsg) > 40)
                            displayMsg := SubStr(displayMsg, 1, 37) . "..."
                        
                        lvMessages.Add("", count, displayMsg, sendTimeStr, timeStr, "Pending")
                    }
                }
            }
        }
    }
    
    ClearQueue(hwnd) {
        if (MessageQueues.Has(hwnd)) {
            ; Cancel all timers
            for msg in MessageQueues[hwnd].Messages {
                if (msg.Timer && !msg.Sent) {
                    SetTimer(msg.Timer, 0)
                }
            }
            MessageQueues.Delete(hwnd)
            RefreshList()
            ShowNotification("Queue cleared!", "All messages cancelled")
        }
    }
    
    ; Show GUI
    viewGui.Show()
}

; Add message to queue
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
    sendTime := DateAdd(A_Now, delayMs//1000, "Seconds")
    
    ; Create timer function
    timerFunc := () => SendScheduledMessage(hwnd, MessageID)
    
    msg := {
        ID: MessageID,
        Text: message,
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
    queueSize := MessageQueues[hwnd].Messages.Length
    
    ShowNotification("✓ Message Scheduled", 
                     "Sends in: " . timeStr . "`nQueue size: " . queueSize . 
                     "`n`nPress Shift+F9 to view queue")
}

; Send scheduled message
SendScheduledMessage(hwnd, msgID) {
    global MessageQueues
    
    if (!WinExist(hwnd) || !MessageQueues.Has(hwnd))
        return
    
    ; Find message
    for msg in MessageQueues[hwnd].Messages {
        if (msg.ID = msgID && !msg.Sent) {
            try {
                ; Activate window
                WinActivate(hwnd)
                Sleep(200)
                
                ; Clear any existing text first
                Send("^a")  ; Select all
                Sleep(50)
                
                ; Type the specific message
                SendText(msg.Text)
                Sleep(200)
                
                ; Send Enter
                Send("{Enter}")
                
                ; Mark as sent
                msg.Sent := true
                
                ShowNotification("✓ Message Sent", 
                                MessageQueues[hwnd].Title . "`n" . msg.Text)
            } catch {
                ShowNotification("✗ Send Failed", 
                                "Could not send to: " . MessageQueues[hwnd].Title)
            }
            break
        }
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
    else if (RegExMatch(input, "^\d+$"))  ; Just number = minutes
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

; Startup message
ShowNotification("Queue Scheduler Ready!", 
                 "F9 = Add message`nShift+F9 = View queue")