#!/bin/bash

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: AutoHotkey Message Queue Scheduler for Claude Code

- Schedule multiple messages for command prompt windows
- Perfect for overnight Claude Code sessions
- Queue messages with custom delays (seconds/minutes/hours)
- Visual queue management with Shift+F9
- Each window maintains independent message queue"

# Create GitHub repository using GitHub CLI
gh repo create claude-message-scheduler --public --description "AutoHotkey tool for scheduling messages in command prompt windows - perfect for overnight Claude Code sessions" --remote origin

# Push to GitHub
git push -u origin main

echo "Repository created and pushed to GitHub!"
echo "Visit: https://github.com/MattPears1/claude-message-scheduler"