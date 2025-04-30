#!/bin/bash

# Ask the user if they want to stash changes
read -p "Do you want to stash your changes? (y/n): " response

# Convert response to lowercase
response=${response,,}

# Check if the response is 'y' or 'yes'
if [[ "$response" == "y" || "$response" == "yes" ]]; then
    echo "Stashing changes..."
    git stash
    echo "Changes stashed."
else
    echo "Skipping stash."
fi

# Delete all local changes
echo "Deleting all local changes..."
git reset --hard
git clean -fd
echo "All local changes deleted."

