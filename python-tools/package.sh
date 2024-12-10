function dependencies() {
    echo "pipx"
}

function install_package() {
    pipx install poetry
    pipx install ruff
}

function uninstall_package() {
    pipx uninstall poetry
    pipx uninstall ruff
}
