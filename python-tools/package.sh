function dependencies() {
    echo "pipx"
}

function install_package() {
    pipx install poetry
    pipx install ruff
    pipx install mypy
}

function uninstall_package() {
    pipx uninstall poetry
    pipx uninstall ruff
    pipx uninstall mypy
}
