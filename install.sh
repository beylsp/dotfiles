#!/bin/bash

# configuration
REPO_URL="https://github.com/beylsp/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$DOTFILES_DIR/config"
BASHRC="$HOME/.bashrc"
BACKUP_DIR="$HOME/dotfiles_backup"

# clone dotfiles repo if it doesn't already exist
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning dotfiles repo to $DOTFILES_DIR ..."
    git clone --quiet "$REPO_URL" "$DOTFILES_DIR"
else
    echo "Dotfiles directory already exists. Pulling latest changes ..."
    git -C "$DOTFILES_DIR" pull --quiet
fi

# create backup directory if it doesn't exist and backup original .bashrc
mkdir -p "$BACKUP_DIR"
if [ -f "$BASHRC" ]; then
    timestamp=$(date +%Y%m%d%H%M%S)
    backup_file="$BACKUP_DIR/bashrc_backup_$timestamp"
    echo "Backing up original .bashrc to $backup_file ..."
    cp "$BASHRC" "$backup_file"
else
    echo "No existing .bashrc found to back up"
fi

# add sourcing lines to .bashrc if not already present
add_source_line() {
    local file=$1
    local source_line="source $file"

    if ! grep -Fxq "$source_line" "$BASHRC"; then
        echo "Adding source line for $file in $BASHRC ..."
        echo "$source_line" >> "$BASHRC"
    else
        echo "Source line for $file already present in $BASHRC"
    fi
}

# add source lines for each config file in $CONFIG_DIR
echo "Setting up .bashrc to source custom dotfiles ..."

for file in "$CONFIG_DIR"/*; do
    add_source_line "$file"
done

echo "Dotfiles setup complete!"
echo "To apply changes, please restart your terminal or run:"
echo "source ~/.bashrc"