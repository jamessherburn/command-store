#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if fzf is installed, and install it if not
if ! command_exists fzf; then
    echo "fzf is not installed. Installing fzf..."
    if command_exists brew; then
        brew install fzf
    else
        echo "Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi
fi

# Navigate to the $HOME/code directory
cd "$HOME/code" || { echo "Directory $HOME/code does not exist."; exit 1; }

# List only directories that are Git repositories
repos=()
for dir in */; do
    if [ -d "$dir/.git" ]; then
        repos+=("$dir")
    fi
done

# Check if there are any Git repositories
if [ ${#repos[@]} -eq 0 ]; then
    echo "No Git repositories found in $HOME/code."
    exit 1
fi

# Use fzf for interactive selection
selected_dir=$(printf "%s\n" "${repos[@]}" | fzf --height 10 --border --prompt="Select a GitHub repo: ")

# Check if a directory was selected
if [ -z "$selected_dir" ]; then
    echo "No directory selected."
    exit 1
fi

# Change to the selected directory
cd "$selected_dir" || { echo "Failed to change directory to $selected_dir"; exit 1; }

# Check if the directory is a Git repository
if [ -d ".git" ]; then
    echo "This is a Git repository."

    # Get a list of all local branches except 'main' and 'master'
    branches_to_delete=$(git branch | grep -vE '^\*|main|master')

    # Count the number of branches to be deleted
    branch_count=$(echo "$branches_to_delete" | wc -l)

    # Delete the branches, skipping warnings
    if [ "$branch_count" -gt 0 ]; then
        echo "$branches_to_delete" | xargs git branch -D
        echo "$branch_count branches were removed."
    else
        echo "No branches to remove."
    fi
else
    echo "This is not a Git repository."
fi

