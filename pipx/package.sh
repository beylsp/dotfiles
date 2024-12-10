SUDO_NEEDED="yes"

function dependencies() {
    echo "wsl-essential"
}

function install_package() {
    sudo apt install -y \
        pipx
    pipx ensurepath
}

function uninstall_package() {
    sudo apt-get purge -y \
        pipx
}

function init_package() {
    export PIPX_DEFAULT_PYTHON=python3.12
}

function uninit_package() {
    unset PIPX_DEFAULT_PYTHON
}
