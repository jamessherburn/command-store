#!/bin/bash

# Get the name of the current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Check out the staging branch
git checkout staging

# Fetch updates from the remote repository
git fetch origin

# Pull any new commits from the remote staging branch
git pull origin staging

# Merge the original branch into staging
git merge "$current_branch"

echo "Merged $current_branch into staging."

