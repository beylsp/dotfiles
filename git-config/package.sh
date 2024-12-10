function install_package() {
    ln -sf ${DOTFILES_ROOT}/git-config/.gitconfig ${HOME}/.gitconfig
}

function uninstall_package() {
    rm -f ${HOME}/.gitconfig
}