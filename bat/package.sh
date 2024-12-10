function install_package() {
    local version=0.24.0
    local tarball=bat-v${version}-x86_64-unknown-linux-musl.tar.gz
    local checksum=d39a21e3da57fe6a3e07184b3c1dc245f8dba379af569d3668b6dcdfe75e3052

    curl -L https://github.com/sharkdp/bat/releases/download/v${version}/${tarball} --output /tmp/${tarball}
    if [ "${checksum}" != $(sha256sum /tmp/${tarball} | awk '{print $1}') ]; then
        echo "Error: Checksum doesn't match for ${tarball}!" >&2
        return 1
    fi

    mkdir -p /tmp/bat-${version}/
    tar -C /tmp/bat-${version} -xvf /tmp/${tarball}

    find /tmp/bat-${version} -name "bat"      -type f -exec mv {} ${DOTFILES_BIN}/ \;
    find /tmp/bat-${version} -name "bat.bash" -type f -exec mv {} ${DOTFILES_COMPLETION}/ \;
    find /tmp/bat-${version} -name "bat.1"    -type f -exec mv {} ${DOTFILES_MAN1} \;

    rm -rv \
        /tmp/${tarball} \
        /tmp/bat-${version}/
}

function uninstall_package() {
    rm -fv \
        ${DOTFILES_BIN}/bat \
        ${DOTFILES_COMPLETION}/bat.bash \
        ${DOTFILES_MAN1}/bat.1
}

function init_package() {
    source ${DOTFILES_COMPLETION}/bat.bash
}