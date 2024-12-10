function install_package() {
    local version=1.23.3
    local tarball=go${version}.linux-amd64.tar.gz
    local checksum=a0afb9744c00648bafb1b90b4aba5bdb86f424f02f9275399ce0c20b93a2c3a8

    curl -L https://go.dev/dl/${tarball} --output /tmp/${tarball}
    if [ "${checksum}" != $(sha256sum /tmp/${tarball} | awk '{print $1}') ]; then
        echo "Error: Checksum doesn't match for ${tarball}!" >&2
        return 1
    fi

    tar -C ${DOTFILES_PREFIX} -xzf /tmp/${tarball}
    rm -rf /tmp/${tarball}
}

function uninstall_package() {
    rm -rvf ${DOTFILES_PREFIX}/go
}

function init_package() {
    export PATH=${DOTFILES_PREFIX}/go/bin:${PATH}
}

function uninit_package() {
    export PATH=$(echo $PATH | tr ':' '\n' | grep -v ${DOTFILES_PREFIX}/go/bin | tr '\n' ':')
}