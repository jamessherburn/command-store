#!/bin/bash

# Define the file path
FILE="$HOME/daily-notes.txt"

# Check if the file exists, if not, create it
if [ ! -f "$FILE" ]; then
    touch "$FILE"
fi

# Get the current date in the desired format
CURRENT_DATE=$(date +"%d %B %Y")

# Append the note to the file
echo -e "\n[$CURRENT_DATE]\n$1\n" >> "$FILE"

bash ~/scripts/gnotes-gen-html.sh
