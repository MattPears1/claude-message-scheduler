# Troubleshooting Guide

## Message Appears But Doesn't Send

**Problem**: The message text appears in the command prompt but Enter isn't pressed

**Solutions**:
1. Use the Smart Scheduler (`START_SmartScheduler.bat`) which verifies sending
2. The updated script now tries 3 different methods to send Enter
3. Make sure the command prompt window is not minimized
4. Some terminals may need different key combinations

**Quick Fix**: If a message fails to send, just click in the window and press Enter manually

## Scheduler Interrupts Your Work

**Problem**: Messages activate windows while you're using the computer

**Solutions**:
1. Use Smart Scheduler with "Wait until I'm inactive" option
2. Schedule messages for times you won't be at the computer
3. Use Ctrl+F9 to pause all schedules when you need to work
4. Set longer inactivity threshold in settings

## Messages Send to Wrong Window

**Problem**: Active window changes before message sends

**Solutions**:
1. Smart Scheduler locks onto the specific window
2. Don't close the target window after scheduling
3. Minimize other windows if needed

## Best Practices

1. **Test First**: Schedule a test message with 30s delay
2. **Space Messages**: Leave 15-30 minutes between messages
3. **Clear Messages**: Write complete, standalone messages
4. **Stay Logged In**: Ensure your session won't timeout
5. **Check Morning**: Review what was sent and completed

## Overnight Setup Checklist

Before leaving for the night:
- [ ] All Claude Code windows are open
- [ ] Computer set to not sleep
- [ ] Screensaver disabled
- [ ] Test one message first
- [ ] Use Smart Scheduler for reliability