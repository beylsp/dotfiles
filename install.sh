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

# dynamically create a list of files to symlink, excluding those starting with bash_
FILES_TO_SYMLINK=()
for file in "$CONFIG_DIR"/*; do
    # only add files that do not start with 'bash_'
    if [[ -f "$file" && $(basename "$file") != bash_* ]]; then
        FILES_TO_SYMLINK+=("$(basename "$file")")
    fi
done

# create backup directory if it doesn't exist and backup original .bashrc
mkdir -p "$BACKUP_DIR"

# create backups and symlinks for the files in FILES_TO_SYMLINK
for file in "${FILES_TO_SYMLINK[@]}"; do
    target="$HOME/.$file"
    source="$CONFIG_DIR/$file"

    # backup existing file if it already exists (and isn't a symlink)
    if [ -f "$target" ] && [ ! -L "$target" ]; then
        timestamp=$(date +%Y%m%d%H%M%S)
        backup_file="$BACKUP_DIR/${file}_backup_$timestamp"
        echo "Backing up original $target to $backup_file"
        cp "$target" "$backup_file"
    fi

    # create a symlink, overwriting any existing symlink
    echo "Creating symlink for $file in home directory."
    ln -sf "$source" "$target"
done

# create backup for original .bashrc
if [ -f "$BASHRC" ]; then
    timestamp=$(date +%Y%m%d%H%M%S)
    backup_file="$BACKUP_DIR/bashrc_backup_$timestamp"
    echo "Backing up original .bashrc to $backup_file ..."
    cp "$BASHRC" "$backup_file"
else
    echo "No existing .bashrc found to back up"
fi

# define the block to source all bash_* files from the config directory
SOURCE_BLOCK="
# Source all bash_* files from dotfiles/config if they exist
DOTFILES_DIR=\"$CONFIG_DIR\"

for config_file in \"\$DOTFILES_DIR\"/bash_*; do
    if [ -f \"\$config_file\" ]; then
        source \"\$config_file\"
    fi
done
"

# add the sourcing block to .bashrc if it doesn't already exist
if ! grep -Fxq "# Source all bash_* files from dotfiles/config if they exist" "$BASHRC"; then
    echo "$SOURCE_BLOCK" >> "$BASHRC"
    echo "Added dotfiles sourcing block to .bashrc"
fi

echo
echo "Dotfiles setup complete!"
echo "To apply changes, please restart your terminal or run:"
echo "source ~/.bashrc"