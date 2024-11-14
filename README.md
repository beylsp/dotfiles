# Dotfiles Repository

This repository contains dotfiles and configuration scripts for setting up a consistent development environment across multiple machines.

## Installation

### Quick Install with `wget` or `curl`

To install the dotfiles and configure your environment, you can run the following command:

Using `wget`:
```bash
wget -qO - https://raw.githubusercontent.com/beylsp/dotfiles/refs/heads/main/install.sh | bash
```

Or, using `curl`:
```bash
curl -sSL https://raw.githubusercontent.com/beylsp/dotfiles/refs/heads/main/install.sh | bash
```

This command will:

1. Clone the dotfiles repository to `~/dotfiles`.
2. Backup any existing `.bashrc` and other config files (like `.gitconfig`) to a `~/dotfiles_backup` directory.
3. Create symlinks from the `~/dotfiles/config` directory to your home directory for all configuration files except those starting with `bash_`.
4. Automatically source all `bash_*` files from the `~/dotfiles/config` directory in your `.bashrc`.

### Manual Install

If you prefer, you can manually clone the repository and run the installer script:

```bash
git clone https://github.com/beylsp/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Repository Structure

```bash
dotfiles/
│
├── config/                 # All dotfiles are in this directory
│   ├── bash_aliases
│   ├── bash_exports        # Environment variables
│   ├── gitconfig           # symlinked to ~
│   └── ...
│
├── install.sh              # Installation script
└── README.md               # This README file
```

* `config/`: Contains all configuration files.
* `install.sh`: The main installer script that sets up the dotfiles, backs up existing configurations, and sources the main `.bashrc` for modular loading of other settings.

## Customization

You can add new configuration files. Simply commit and push any changes to keep your setup in sync across machines.

* **Adding More Config Files**: The script dynamically detects all configuration files in the `~/dotfiles/config` directory (except those starting with `bash_`). You can add additional config files, and the script will automatically symlink them.
* **Bash Configurations**: Any file starting with `bash_` (e.g., `bash_aliases`, `bash_exports`, `bash_functions`) will be sourced in your `.bashrc` automatically. You can add new `bash_*` files to the `~/dotfiles/config` directory, and they will be sourced without additional changes to `.bashrc`.

### Updating Your Dotfiles

To update the dotfiles on a machine, simply navigate to `~/dotfiles` and pull the latest changes:

```bash
cd ~/dotfiles
git pull
./install.sh
```

This will update your environment with any new configurations you’ve added to the repository.

## License

This project is licensed under the MIT License. Feel free to use and modify it as you like.