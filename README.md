# AutoHotkey Message Queue Scheduler for Claude Code

A Windows automation tool that lets you schedule messages to be sent automatically in command prompt windows, perfect for overnight Claude Code sessions.

## What It Does

This AutoHotkey script allows you to:
- Schedule multiple messages to be sent at specific times
- Manage multiple command prompt windows independently
- Queue messages hours in advance
- Run Claude Code tasks overnight while you sleep

## Who It's For

Created by a developer using Claude Code Pro subscription. Getting the most out of the subscription means using it 24/7 and this tool allows you to do this.

## Installation

1. **Download and Install AutoHotkey v2**
   - Download from [autohotkey.com](https://www.autohotkey.com/)
   - Run the installer (included in this repo as `AutoHotkey_v2_Setup.exe`)

2. **Clone this repository**
   ```bash
   git clone https://github.com/MattPears1/claude-message-scheduler.git
   cd claude-message-scheduler
   ```

3. **Run the scheduler**
   - Double-click `START_CommandPromptQueue.bat`
   - You'll see a confirmation that the scheduler is running

## How to Use

1. **Open your Claude Code sessions** in command prompt windows
2. **Press F9** to schedule a message
   - A dialog appears asking for your message and delay time
   - Enter delay as: `30s` (seconds), `5m` (minutes), or `2h` (hours)
3. **Press Shift+F9** to view all scheduled messages
4. **Messages send automatically** at their scheduled times

## Suggested Overnight Messages for Claude Code

Since you'll be asleep, schedule messages that Claude can complete autonomously:

### Code Analysis & Documentation
- "Please analyze the entire codebase and create a comprehensive documentation file"
- "Review all functions and add JSDoc comments where missing"
- "Generate a dependency graph and identify unused imports"

### Code Cleanup & Refactoring
- "Please refactor all files to follow consistent naming conventions"
- "Find and fix all ESLint warnings in the project"
- "Identify duplicate code blocks and suggest refactoring opportunities"

### Testing & Quality
- "Generate unit tests for all utility functions"
- "Create test cases for edge scenarios in the API endpoints"
- "Run a security audit and document any vulnerabilities found"

### Project Organization
- "Reorganize the folder structure following best practices"
- "Create a detailed project roadmap based on the current code"
- "Generate API documentation from the existing endpoints"

### Performance Analysis
- "Analyze the codebase for performance bottlenecks"
- "Identify O(n²) or worse algorithms and suggest optimizations"
- "Review database queries and suggest indexing improvements"

## Example Schedule

Set up before bed:
```
23:00 - "Please analyze the entire project structure and create a detailed report"
01:00 - "Review all error handling and suggest improvements"
03:00 - "Generate comprehensive test coverage report"
05:00 - "Create developer documentation for onboarding"
07:00 - "Summarize all the work completed overnight"
```

## Features

- **Multiple Windows**: Each command prompt window has its own message queue
- **Visual Queue**: Press Shift+F9 to see all pending messages with countdown timers
- **Precise Timing**: Messages send exactly when scheduled
- **Auto-Clear**: Input field clears after sending for clean operation

## System Requirements

- Windows 10/11
- AutoHotkey v2
- Command Prompt or Terminal application

## License

MIT License - Free for anyone to use and modify

## Author

Created by Matt Pears (MattPears1) - Developer

Using this with Claude Code Pro to maximize productivity through overnight automated sessions.

## Contributing

Feel free to fork and submit pull requests. Suggestions for improving overnight automation workflows are welcome!

## Disclaimer

This tool types and sends messages automatically. Ensure you've reviewed what tasks you're scheduling before leaving it unattended.