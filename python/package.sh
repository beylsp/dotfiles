function dependencies() {
    echo "hatch"
}

function install_package() {
    local pyversions="3.9 3.10 3.11 3.12 3.13"

    mkdir -pv ${DOTFILES_PREFIX}/python
    hatch python install -d ${DOTFILES_PREFIX}/python ${pyversions} 
}

function uninstall_package() {
    hatch python remove -d ${DOTFILES_PREFIX}/python all
}