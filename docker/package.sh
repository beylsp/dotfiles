SUDO_NEEDED="yes"

function dependencies() {
    echo "wsl-essential"
}

function install_package() {
    # ensure we aren't running older versions
    local old_packages=("docker" "docker.io" "containerd" "runc" "docker-engine")
    for package in "${packages[@]}"; do
        sudo apt-get remove -y ${package} || true
    done

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg |\
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" |\
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    sudo systemctl enable docker
    sudo systemctl start docker

    mkdir -pv ${DOTFILES_SHARE}/docker
    ln -sf ${DOTFILES_ROOT}/docker/docker-aliases.sh ${DOTFILES_SHARE}/docker/docker-aliases.sh
}

function uninstall_package() {
    sudo systemctl stop docker
    sudo systemctl disable docker

    sudo apt-get purge -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
        docker-ce-rootless-extras

    sudo rm -rvf /var/lib/docker
    sudo rm -rvf /var/lib/containerd

    sudo rm -vf /etc/apt/keyrings/docker.gpg
    sudo rm -vf /etc/apt/sources.list.d/docker.list
}

function init_package() {
    source ${DOTFILES_SHARE}/docker/docker-aliases.sh
}