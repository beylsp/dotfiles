# Dotfiles Repository

This repository contains dotfiles and configuration scripts for setting up a consistent development environment across multiple machines.

## Installation

### Quick Install with `wget` or `curl`

To install the dotfiles and configure your environment, you can run the following command:

Using `wget`:
```bash
wget -O - https://raw.githubusercontent.com/beylsp/dotfiles/main/install.sh | bash
```

Or, using `curl`:
```bash
curl -sSL https://raw.githubusercontent.com/beylsp/dotfiles/main/install.sh | bash
```

This command will:

1. Clone the dotfiles repository to `~/dotfiles`.
2. Backup any existing `.bashrc` to a `~/dotfiles_backup` directory.
3. Source the main bashrc configuration file, allowing modular sourcing of additional configurations like aliases, exports, and more.

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
│   ├── aliases.sh
│   ├── exports.sh
│   └── ...
│
├── install.sh              # Installation script
└── README.md               # This README file
```

* `config/`: Contains all configuration files. The installer script will source each file in this directory from your `.bashrc` file.
* `install.sh`: The main installer script that sets up the dotfiles, backs up existing configurations, and sources the main .bashrc for modular loading of other settings.

## Customization

You can add new configuration files and source them within bashrc as needed. Simply commit and push any changes to keep your setup in sync across machines.

### Updating Your Dotfiles

To update the dotfiles on a machine, simply navigate to ~/dotfiles and pull the latest changes:

```bash
cd ~/dotfiles
git pull
./install.sh
```

This will update your environment with any new configurations you’ve added to the repository.

## License

This project is licensed under the MIT License. Feel free to use and modify it as you like.