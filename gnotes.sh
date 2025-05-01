#!/bin/bash

# Define the file path
FILE="$HOME/daily-notes.txt"

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "The notes file does not exist."
    exit 1
fi

# Read the contents of the file
NOTES_CONTENT=$(cat "$FILE")

# Copy to clipboard
if command -v xclip &> /dev/null; then
    # For Linux using xclip
    echo "$NOTES_CONTENT" | xclip -selection clipboard
    echo "Notes copied to clipboard using xclip."
elif command -v pbcopy &> /dev/null; then
    # For macOS using pbcopy
    echo "$NOTES_CONTENT" | pbcopy
    echo "Notes copied to clipboard using pbcopy."
else
    echo "No clipboard utility found. Please install xclip (Linux) or use macOS."
    exit 1
fi

