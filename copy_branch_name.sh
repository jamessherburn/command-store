#!/bin/bash

# Get the current git branch name
branch_name=$(git rev-parse --abbrev-ref HEAD)

# Copy the branch name to the clipboard
echo -n "$branch_name" | pbcopy

echo "Branch name '$branch_name' copied to clipboard."
