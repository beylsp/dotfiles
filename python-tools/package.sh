function dependencies() {
    echo "pipx"
}

function install_package() {
    pipx install poetry
    pipx install ruff
    pipx install mypy
    pipx install uv
}

function uninstall_package() {
    pipx uninstall poetry
    pipx uninstall ruff
    pipx uninstall mypy
    pipx uninstall uv
}
