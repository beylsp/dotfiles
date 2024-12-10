#!/bin/false


###################################################################################################
## Environment Variables
###################################################################################################

export DOTFILES_ROOT=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
export DOTFILES_PREFIX=${HOME}/.local
export DOTFILES_BIN=${DOTFILES_PREFIX}/bin
export DOTFILES_SHARE=${DOTFILES_PREFIX}/share
export DOTFILES_INSTALLED=${DOTFILES_SHARE}/dotfiles
export DOTFILES_COMPLETION=${DOTFILES_SHARE}/completion
export DOTFILES_FONTS=${DOTFILES_SHARE}/fonts
export DOTFILES_CONFIG=${HOME}/.config
export DOTFILES_MAN=${DOTFILES_PREFIX}/man
export DOTFILES_MAN1=${DOTFILES_MAN}/man1

###################################################################################################
## Private Functions
###################################################################################################

function __dotfiles_info() {
    local msg=${1}
    local white_on_green="\e[97m\e[102m"
    local normal="\e[0m"
    echo
    printf "${white_on_green}------------------------------------------------------------${normal}\n"
    printf "${white_on_green}-- %-57s${normal}\n" "${msg}"
    printf "${white_on_green}------------------------------------------------------------${normal}\n"
    echo
}

function __dotfiles_error() {
    local msg=${1}
    local black_on_red="\e[97m\e[101m"
    local normal="\e[0m"

    echo
    printf "${black_on_red}------------------------------------------------------------${normal}\n"
    printf "${black_on_red}-- %-57s${normal}\n" "${msg}"
    printf "${black_on_red}------------------------------------------------------------${normal}\n"
    echo
}

function  __dotfiles_bootstrap() {
    mkdir -p \
        ${DOTFILES_BIN} \
        ${DOTFILES_SHARE} \
        ${DOTFILES_INSTALLED} \
        ${DOTFILES_COMPLETION} \
        ${DOTFILES_FONTS} \
        ${DOTFILES_MAN1} \
        ${DOTFILES_CONFIG}
    __dotfiles_init
}

function __dotfiles_init() {
    export PATH=${DOTFILES_BIN}:${PATH}

    for installed_package in $(find -L ${DOTFILES_INSTALLED} -maxdepth 2 -name package.sh); do

        # verify if the package has an init function
        local exists=$( \
            set -eou pipefail;
            unset -f init_package;
            source ${installed_package};
            [[ $(type -t init_package) == function ]] && echo "yes" || echo "no" \
        )

        # if yes, execute the function
        if [ "${exists}" = "yes" ]; then
            source ${installed_package}
            init_package
        fi
    done
}

function __dotfiles_list() {
    local package_list=$(cd ${DOTFILES_ROOT} && find . -maxdepth 2 -name package.sh | awk '{split($0,a,"/"); print a[2]}')
    echo "Available packages (installing packages marked with (*) require sudo): "
    for package in ${package_list}; do
        # verify if sudo is needed for this package
        unset -v SUDO_NEEDED;
        source ${DOTFILES_ROOT}/${package}/package.sh
        if [ "${SUDO_NEEDED:-unset}" = "yes" ]; then
            echo "  ${package} (*)"
        else
            echo "  ${package}"
        fi
    done
}

function __dotfiles_list_installed() {
    (cd ${DOTFILES_INSTALLED} && find -L . -maxdepth 2 -name package.sh | awk '{split($0,a,"/"); print a[2]}')
}

function __dotfiles_check() {
    local green="\e[32m"
    local red="\e[31m"
    local normal="\e[0m"

    for package in $(__dotfiles_list); do
        printf "%-30s" "checking '${package}'..."
        local package_script=${DOTFILES_ROOT}/${package}/package.sh
        local output=$(mktemp -t dotfiles.XXXXX)
        (set -eou pipefail && trap "__dotfiles_error ${package_script}:${LINENO}" ERR && source "${package_script}" &> ${output})
        if [ "$?" -ne 0 ]; then
            printf "${red}KO${normal}\n\n"
            cat ${output}
            rm -f ${output}
            return 1
        fi
        rm -f ${output}
        printf "${green}OK${normal}\n"
    done
     __dotfiles_info "All Good!"
}

function __dotfiles_install() {
    __dotfiles_bootstrap

    # process input arguments and remove duplicates
    pending_packages=$(echo "${@}" | xargs -n1 | awk '!a[$0]++' | xargs)
    for package in ${pending_packages}; do
        local package_script="${DOTFILES_ROOT}/${package}/package.sh"

        # verify package exists
        if [ ! -f "${package_script}" ]; then
            __dotfiles_error "Unknown Package: ${package}!"
            return 1
        fi

        # verify that dependencies function exists
        local exists=$( \
            set -eou pipefail;
            unset -f dependencies;
            source ${package_script};
            [[ $(type -t dependencies) == function ]] && echo "yes" || echo "no" \
        )

        # if yes, execute the function
        if [ "${exists}" = "yes" ]; then
            local output=$(mktemp -t dotfiles.XXXXX)
            (set -eou pipefail && trap "__dotfiles_error ${package_script}:${LINENO}" ERR && source "${package_script}" && dependencies &> ${output})
            if [ "$?" -ne 0 ]; then
                cat ${output}
                rm -f ${output}
                __dotfiles_error "Failed to get dependencies for package: '${package}'!"
                return 1
            fi
            local additional_package=$(cat ${output})
            rm -f ${output}
            pending_packages="${additional_package} ${pending_packages}"
        fi
    done
    local pending_packages=$(echo "${pending_packages}" | xargs -n1 | awk '!a[$0]++' | xargs)

    # check what needs to be installed, skip if already installed
    local packages_to_install=""
    for package in ${pending_packages}; do
        local package_script="${DOTFILES_INSTALLED}/${package}/package.sh"
        if [ ! -f "${package_script}" ]; then
            packages_to_install="${packages_to_install} ${package}"
        else
            __dotfiles_info "Package '${package}' is already installed. Skipping."
        fi
    done

    # perform installation
    for package in ${packages_to_install}; do
        __dotfiles_info "Installing '${package}'..."
        local package_script="${DOTFILES_ROOT}/${package}/package.sh"
        if [ -f "${package_script}" ]; then
            (set -eou pipefail && source ${package_script} && set -x && install_package)
            if [ "$?" -ne 0 ]; then
                __dotfiles_error "Failed to install '${package}'!"
                return 1
            fi

            # verify if the package has an init function
            local exists=$( \
                set -eou pipefail;
                unset -f init_package;
                source ${package_script};
                [[ $(type -t init_package) == function ]] && echo "yes" || echo "no" \
            )

            # if yes, execute the function
            if [ "${exists}" = "yes" ]; then
                source ${package_script} && init_package
                if [ "$?" -ne 0 ]; then
                     __dotfiles_error "Failed to initialize '${package}'!"
                     return 1
                fi
            fi
        else
            __dotfiles_error "Missing script for package '${package}': '${package_script}'!"
            return 1
        fi

        ln -fv -s ${DOTFILES_ROOT}/${package} ${DOTFILES_INSTALLED}/
    done
    return 0
}


function __dotfiles_install_all() {
    __dotfiles_install $(__dotfiles_list)
}

function __dotfiles_uninstall() {
    # process input arguments and remove duplicates
    pending_packages=$(echo "${@}" | xargs -n1 | awk '!a[$0]++' | xargs)
    for package in ${pending_packages}; do
        __dotfiles_info "Uninstalling '${package}'..."
        local package_script="${DOTFILES_INSTALLED}/${package}/package.sh"
        if [ -f "${package_script}" ]; then
            (set -eou pipefail && source ${package_script} && set -x && uninstall_package)
            if [ "$?" -ne 0 ]; then
                 __dotfiles_error "Failed to uninstall '${package}'!"
                return 1
            fi
        
            # verify if the package has an uninit function
            local exists=$( \
                set -eou pipefail;
                unset -f uninit_package;
                source ${package_script};
                [[ $(type -t uninit_package) == function ]] && echo "yes" || echo "no" \
            )

            # if yes, execute the function
            if [ "${exists}" = "yes" ]; then
                source ${package_script} && uninit_package
                if [ "$?" -ne 0 ]; then
                     __dotfiles_error "Failed to uninitialize '${package}'!"
                     return 1
                fi
            fi

            rm -vf ${DOTFILES_INSTALLED}/${package}
        else
            __dotfiles_error "Package not installed: '${package}'!"
            return 1
        fi
    done
}

function __dotfiles_uninstall_all() {
    __dotfiles_uninstall $(__dotfiles_list_installed)
}

function __dotfiles_reinstall() {
    __dotfiles_uninstall "${@}"
    if [ "$?" -ne 0 ]; then
        return 1
    fi
    __dotfiles_install "${@}"
}

function __dotfiles_reinstall_all() {
    __dotfiles_reinstall $(__dotfiles_list_installed)
}

function __dotfiles_help() {
    echo "Usage:"
    echo "    dotfiles <command>"
    echo
    echo "Available Commands:"
    echo "    list                  list available packages"
    echo "    list-installed        list installed packages"
    echo "    check                 check all packages"
    echo "    install               install packages"
    echo "    install-all           install all available packages"
    echo "    uninstall             uninstall packages"
    echo "    uninstall-all         uninstall all packages"
    echo "    reinstall             reinstall packages"
    echo "    reinstall-all         reinstall all packages"
    echo "    help                  print this message"
    echo
    echo "Example:"
    echo "    dotfiles install go"
}

###################################################################################################
## Public Functions
###################################################################################################

function dotfiles() {
    case ${1} in
        list)               __dotfiles_list;;
        list-installed)     __dotfiles_list_installed;;
        check)              __dotfiles_check;;
        install)            __dotfiles_install "${@:2}";;
        install-all)        __dotfiles_install_all "${@:2}";;
        uninstall)          __dotfiles_uninstall "${@:2}";;
        uninstall-all)      __dotfiles_uninstall_all "${@:2}";;
        reinstall)          __dotfiles_reinstall "${@:2}";;
        reinstall-all)      __dotfiles_reinstall_all "${@:2}";;
        *)                  __dotfiles_help;;
    esac

    case ${1} in
        install|uninstall|reinstall)
            if [ "$?" -eq 0 ]; then
                __dotfiles_info "Finished!"
            fi
            ;;
    esac
}

__dotfiles_bootstrap