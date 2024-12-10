function install_package() {
    local version=1.21.1
    local tarball=starship-x86_64-unknown-linux-musl.tar.gz
    local checksum=744e21eb2e61b85b0c11378520ebb9e94218de965bca5b8c2266f6c3e23ff5be

    curl -L https://github.com/starship/starship/releases/download/v${version}/${tarball} --output /tmp/${tarball}
    if [ "${checksum}" != $(sha256sum /tmp/${tarball} | awk '{print $1}') ]; then
        echo "Error: Checksum doesn't match for ${tarball}!" >&2
        return 1
    fi

    tar -C ${DOTFILES_BIN} -xvf /tmp/${tarball}
    rm -fv /tmp/${tarball}
    ln -fs ${DOTFILES_ROOT}/starship/starship.toml ${DOTFILES_CONFIG}/
}

function uninstall_package() {
    rm -fv \
        ${DOTFILES_CONFIG}/starship.toml \
        ${DOTFILES_BIN}/starship
}

function init_package() {
    set +u
    eval "$(starship init bash)"
}

function uninit_package() {
    unset PROMPT_COMMAND
    unset PS1
    unset PS2
    source ${HOME}/.bashrc
}
