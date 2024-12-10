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

### Manual Install

If you prefer, you can manually clone the repository and run the installer script:

```bash
git clone https://github.com/beylsp/dotfiles.git ~/.dotfiles
echo ". ~/.dotfiles/provision.sh" >> ~/.bashrc
cd ~/.dotfiles
./install.sh
```
