function install_package() {
    local version=0.56.3
    local tarball=fzf-${version}-linux_amd64.tar.gz
    local checksum=78e96a88cecfbdb3ff65df89cc47c02573407aee0edd08c87e18a8033d498fef

    curl -L https://github.com/junegunn/fzf/releases/download/v${version}/${tarball} --output /tmp/${tarball}
    if [ "${checksum}" != $(sha256sum /tmp/${tarball} | awk '{print $1}') ]; then
        echo "Error: Checksum doesn't match for ${tarball}!" >&2
        return 1
    fi

    mkdir -p /tmp/fzf-${version}
    tar -C /tmp/fzf-${version} -xvf /tmp/${tarball}

    find /tmp/fzf-${version} -name "fzf" -type f -exec mv {} ${DOTFILES_BIN}/ \;

    mkdir -pv ${DOTFILES_SHARE}/fzf
    curl -L https://raw.githubusercontent.com/junegunn/fzf/v${version}/shell/key-bindings.bash --output ${DOTFILES_SHARE}/fzf/key-bindings.bash

    rm -rf \
        /tmp/${tarball} \
        /tmp/fzf-${version}
}

function uninstall_package() {
    rm -vf ${DOTFILES_BIN}/fzf ${DOTFILES_SHARE}/fzf/key-bindings.bash
}

function init_package() {
    source ${DOTFILES_SHARE}/fzf/key-bindings.bash
}