#!/bin/bash

# Function to capitalize each word in a string
capitalize() {
  echo "$1" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1'
}

# Check if the current directory is a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Error: This is not a git repository."
  exit 1
fi

# Ask for user input
read -p "Enter your ticket number (e.g., 123): " ticket_number
read -p "Enter the title for your pull request: " pr_title
read -p "Explain why you are doing this PR: " pr_why
read -p "Explain what you have done: " pr_what

# Capitalize the title
capitalized_title=$(capitalize "$pr_title")

# Check the current branch
current_branch=$(git branch --show-current)

# Check if the current branch is master, main, or staging
if [[ "$current_branch" == "master" || "$current_branch" == "main" || "$current_branch" == "staging" ]]; then
  echo "Warning: You cannot commit directly on master, main, or staging. A new branch will be created."
  create_new_branch=true
else
  read -p "Do you wish to create a new branch? (y/n): " create_new_branch
fi

# Create a new branch if needed
if [[ "$create_new_branch" == "y" || "$create_new_branch" == "Y" || "$create_new_branch" == true ]]; then
  # Replace spaces with dashes and create a new branch name
  branch_name="CMRCH-$ticket_number/$(echo "$pr_title" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
  git checkout -b "$branch_name"
  current_branch="$branch_name"  # Update current_branch to the new branch
fi

# Construct the JIRA ticket URL
jira_url="<your base url>-$ticket_number"

# Create the commit message
commit_message="[<your prefix>-$ticket_number] - [$capitalized_title]

[See The JIRA Ticket]($jira_url)

Why:
$pr_why

What:
$pr_what"

# Create the commit
git add .
git commit -m "$commit_message"

echo "Commit created successfully."

# Ask the user if they want to push the changes
read -p "Do you want to push the changes to the remote repository? (y/n): " push_now

if [[ "$push_now" == "y" || "$push_now" == "Y" ]]; then
  git push -u origin "$current_branch"
  echo "Changes pushed to the remote repository."

  # Get the remote URL and convert it to the GitHub PR URL
  remote_url=$(git config --get remote.origin.url)
  if [[ "$remote_url" == git@github.com:* ]]; then
    # Convert SSH URL to HTTPS URL
    repo_url="https://github.com/${remote_url#git@github.com:}"
  elif [[ "$remote_url" == https://github.com/* ]]; then
    repo_url="$remote_url"
  else
    echo "Error: Unsupported remote URL format."
    exit 1
  fi

  # Remove the .git suffix if present
  repo_url="${repo_url%.git}"

  # Open the GitHub PR page in the default web browser
  open "${repo_url}/compare/${current_branch}?expand=1"
else
  echo "Changes not pushed."
fi

