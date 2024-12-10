SUDO_NEEDED="yes"

function install_package() {
    # disable sudo password
    CURRENT_USER=$(whoami)
    SUDOERS_RULE="${CURRENT_USER} ALL=(ALL) NOPASSWD:ALL"

    echo "${SUDOERS_RULE}" | sudo tee /etc/sudoers.d/${CURRENT_USER}_nopasswd > /dev/null
    sudo chmod 0440 /etc/sudoers.d/${CURRENT_USER}_nopasswd

    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
}

function uninstall_package() {
    CURRENT_USER=$(whoami)
    sudo rm -rvf /etc/sudoers.d/${CURRENT_USER}_nopasswd
}