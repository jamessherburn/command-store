# Command Store

This repositroy contains all of the commands that I use on Mac for software development.

## Installation
1. Clone and cd into the root of the repository.
2. Copy the scripts into the HOME directory: `mkdir -p ~/scripts && cp *.sh ~/scripts/`
3. Make sure they're executable: `chmod +x ~/scripts/*`
4. Update your `~/.zshrc` file with the following aliases:

```
alias cbn='~/scripts/copy_branch_name.sh'
alias dlc='~/scripts/delete_local_changes.sh'
alias mis='~/scripts/merge_into_staging.sh'
alias note='~/scripts/note.sh'
```

5. Source your `~/.zshrc` file: `source ~/.zshrc`

You're good to go!
