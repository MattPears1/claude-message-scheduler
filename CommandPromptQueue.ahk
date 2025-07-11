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
    inputGui.Add("Text", "x+10", "Examples: 30s, 5m, 1h, 13:30")
    
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
            MsgBox("Invalid delay format! Use: 30s, 5m, 1h, or 13:30", "Error", "Icon!")
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
    
    ; Create view GUI with cyberpunk theme
    viewGui := Gui("+AlwaysOnTop", "Message Queue - " . title)
    viewGui.BackColor := "0A0A0A"  ; Dark background
    viewGui.MarginX := 20
    viewGui.MarginY := 20
    
    ; Title with cyberpunk style
    titleText := viewGui.Add("Text", "Section w700 Center c00FF41", "═══════════ SCHEDULED TRANSMISSIONS ═══════════")
    titleText.SetFont("s14 Bold", "Consolas")
    
    ; Motivational phrases (randomly selected)
    phrases := [
        "「 The future is automated, and you're already there 」",
        "「 While you sleep, your digital self works 」",
        "「 Time is currency - you're investing wisely 」",
        "「 24/7 productivity unlocked 」",
        "「 Your AI assistant never rests, neither should your ambition 」",
        "「 Scheduling the future, one message at a time 」",
        "「 Efficiency is the new superpower 」",
        "「 You're not procrastinating, you're time-hacking 」",
        "「 Every scheduled message is a step toward your goals 」",
        "「 Automate today, celebrate tomorrow 」",
        "「 Your future self will thank you for this 」",
        "「 Maximum output, minimum input - that's the way 」",
        "「 Work smarter, not harder - you've mastered it 」",
        "「 The grid never sleeps, and neither does progress 」",
        "「 You're writing the code of your own success 」"
    ]
    
    ; Select random phrase
    phraseIndex := Random(1, phrases.Length)
    motivationalText := viewGui.Add("Text", "w700 Center cFF00FF", phrases[phraseIndex])
    motivationalText.SetFont("s10 Italic", "Consolas")
    
    viewGui.Add("Text", "w700 h2 Background00FF41")  ; Neon green line
    
    ; Message list with better column widths
    lvMessages := viewGui.Add("ListView", "w800 r12 Background0A0A0A c00FF41", ["#", "Message", "Send Time", "Countdown", "Status"])
    lvMessages.SetFont("s10", "Consolas")
    
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
    
    ; Set specific column widths
    lvMessages.ModifyCol(1, 40, "Center")   ; # - 40px centered
    lvMessages.ModifyCol(2, 350)            ; Message - 350px
    lvMessages.ModifyCol(3, 100, "Center")  ; Send Time - 100px
    lvMessages.ModifyCol(4, 150, "Center")  ; Countdown - 150px
    lvMessages.ModifyCol(5, 120, "Center")  ; Status - 120px
    
    ; Track selection time
    global SelectedRow := 0
    global SelectionTime := 0
    
    ; Handle selection changes
    lvMessages.OnEvent("ItemSelect", HandleSelection)
    
    HandleSelection(LV, Item, Selected) {
        if (Selected) {
            global SelectedRow := Item
            global SelectionTime := A_TickCount
        }
    }
    
    ; Refresh timer
    RefreshTimer := () => RefreshView()
    SetTimer(RefreshTimer, 1000)
    
    RefreshView() {
        ; Save current selection if it's recent (less than 5 seconds old)
        preserveSelection := false
        if (SelectedRow > 0 && (A_TickCount - SelectionTime) < 5000) {
            preserveSelection := true
            savedSelection := SelectedRow
        }
        
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
        
        ; Restore selection if it was recent
        if (preserveSelection && savedSelection <= lvMessages.GetCount()) {
            lvMessages.Modify(savedSelection, "Select Focus")
            SelectedRow := savedSelection
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
    
    ; Add space before Clear All button
    viewGui.Add("Text", "w20 x+5", "")  ; Spacer
    
    btnClear := viewGui.Add("Button", "w80 x+5", "🗑️ CLEAR ALL")
    btnClear.Opt("Background8B0000")  ; Dark red background
    
    ; Add more space before Close
    viewGui.Add("Text", "w20 x+5", "")  ; Spacer
    
    btnClose := viewGui.Add("Button", "w80 x+5", "&Close")
    
    ; Add cyberpunk styled instructions
    instructionText := viewGui.Add("Text", "xs w700 Center c00FFFF", "[ SELECT MESSAGE → EXECUTE ACTION ]")
    instructionText.SetFont("s9", "Consolas")
    
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
            ; Count pending messages
            pendingCount := 0
            for msg in MessageQueues[hwnd].Messages {
                if (!msg.Sent) {
                    pendingCount++
                }
            }
            
            if (pendingCount > 0) {
                ; Confirmation dialog
                Result := MsgBox("Are you sure you want to clear ALL " . pendingCount . " scheduled messages?`n`nThis cannot be undone!", 
                                "Confirm Clear All", "YesNo Icon! Default2")
                
                if (Result = "No") {
                    return
                }
            }
            
            ; Clear all messages
            for msg in MessageQueues[hwnd].Messages {
                if (!msg.Sent && msg.Timer) {
                    SetTimer(msg.Timer, 0)
                }
            }
            MessageQueues.Delete(hwnd)
            RefreshView()
            ToolTip("✓ All messages cleared!")
            SetTimer(() => ToolTip(), -2000)
        }
    }
    
    btnClose.OnEvent("Click", CloseWindow)
    
    CloseWindow(*) {
        SetTimer(RefreshTimer, 0)
        viewGui.Destroy()
    }
    
    ; Add bottom border
    viewGui.Add("Text", "xs w700 h2 Background00FF41")  ; Neon green line
    
    ; Add system status
    statusText := viewGui.Add("Text", "w700 Center c00FF41", "SYSTEM STATUS: ONLINE | SCHEDULER: ACTIVE | FUTURE: AUTOMATED")
    statusText.SetFont("s8", "Consolas")
    
    ; Show GUI
    viewGui.Show()
}

; Helper functions
ParseDelay(input) {
    input := Trim(input)
    
    ; Check for time format (HH:MM or H:MM)
    if (RegExMatch(input, "^(\d{1,2}):(\d{2})$", &m)) {
        targetHour := Integer(m[1])
        targetMin := Integer(m[2])
        
        ; Validate time
        if (targetHour >= 0 && targetHour <= 23 && targetMin >= 0 && targetMin <= 59) {
            ; Get current time
            currentTime := A_Now
            currentHour := Integer(FormatTime(currentTime, "HH"))
            currentMin := Integer(FormatTime(currentTime, "mm"))
            
            ; Calculate target time today
            targetTime := FormatTime(currentTime, "yyyyMMdd") . Format("{:02d}{:02d}00", targetHour, targetMin)
            
            ; If target time is in the past, assume tomorrow
            if (targetTime <= currentTime) {
                targetTime := DateAdd(targetTime, 1, "Days")
                
                ; Show warning for next day
                ToolTip("Note: " . input . " is in the past.`nScheduling for tomorrow!")
                SetTimer(() => ToolTip(), -3000)
            }
            
            ; Calculate milliseconds until target time
            diffSeconds := DateDiff(targetTime, currentTime, "Seconds")
            return diffSeconds * 1000
        }
    }
    
    ; Original delay formats
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