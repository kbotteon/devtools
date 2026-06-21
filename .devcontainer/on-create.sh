#!/usr/bin/env bash
################################################################################
# On-create setup for devcontainer
# Runs as the non-root user specified in the Dockerfile
################################################################################

LV='/persist'
WS="${LV}/sandboxes"
PKG="${WS}/devtools"

CPYBIN="${LV}/.tools" # For binaries to be downloaded and placed
USRBIN="${LV}/.local" # For the configure prefix when building from source

# Devtools config directory
DTC="${HOME}/.config/devtools"

ARCH="$(dpkg --print-architecture 2>/dev/null || uname -m)"

log()  { printf '\n%s\n' "$*"; }
info() { printf 'INFO: %s\n' "$*" >&2; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
skip() { printf 'SKIP: %s\n' "$1"; }

# Run a named setup function; log its name and continue on failure
run_step() {
    local name="$1"; shift
    info "${name}"
    if ! "$@"; then
        warn "${name}"
    fi
}

#-------------------------------------------------------------------------------
# Steps
#-------------------------------------------------------------------------------

setup_persist() {

    # In Codespaces, redirect /persist to /workspaces (the only durable storage);
    # locally a Docker volume is mounted directly at /mnt/persist
    if [ -n "${CODESPACES:-}" ]; then
        mkdir -p /workspaces/.persist
        sudo ln -sfn /workspaces/.persist /persist
    fi

    sudo chown -R "$(whoami):" "${LV}"
    chmod 755 "${LV}"

    # On first run with a fresh Docker volume, HOME won't exist yet
    if [ ! -d "${HOME}" ]; then
        mkdir -p "${HOME}"
        cp -a /etc/skel/. "${HOME}/" 2>/dev/null || true
    fi

    chmod 755 "${HOME}"

    # Rebuilds can nest a new skel inside the existing home
    [ -d "${HOME}/home" ] && rm -rf "${HOME}/home"

    mkdir -p "${WS}" "${CPYBIN}" "${USRBIN}" "${HOME}/Desktop"

    # Adjust ldconfig for '--prefix=/persist/.local' source builds
    printf '%s/.local/lib\n' "${LV}" \
        | sudo tee /etc/ld.so.conf.d/persist-local.conf > /dev/null

    # De-clutter home
    rmdir "${HOME}"/{Documents,Music,Pictures,Public,Templates,Videos} 2>/dev/null || true
}


setup_devtools() {
    # Codespaces forces a /workspaces bind mount; symlink it into sandboxes
    if [ -d "/workspaces/devtools" ]; then
        ln -sfn /workspaces/devtools "${WS}/devtools"
    elif [ ! -d "${WS}/devtools" ]; then
        git clone https://github.com/kbotteon/devtools.git "${WS}/devtools"
    fi

    # Other symlinks expect to find devtools in home
    ln -sfn "${WS}/devtools" "${HOME}/devtools"
}

setup_shell() {

    mkdir -p "${DTC}"
    CFG="${DTC}/config"
    touch ${CFG}
    touch "${DTC}/history"

    # Set up a default devtools config
    if ! grep -qF 'DTC_CLEAN_HISTORY' "${DTC}" 2>/dev/null; then
        echo "export DTC_CLEAN_HISTORY=1" >> "${CFG}"
        echo "source ${PKG}/shell/my.sh" >> "${CFG}"
    fi

    if [ -n "${CODESPACE_NAME:-}" ]; then
        echo "export DTC_FRIENDLY_NAME='${CODESPACE_NAME%-*}'" >> "${CFG}"
    fi

    if ! grep -qF 'develop.zsh' "${HOME}/.zshrc" 2>/dev/null; then
        printf '\nsource %s/shell/develop.zsh\n' "${PKG}" >> "${HOME}/.zshrc"
    fi
}

setup_git() {
    if ! grep -qF 'devtools/config/gitconfig' "${HOME}/.gitconfig" 2>/dev/null; then
        printf '\n[include]\n    path = %s/config/gitconfig\n' "${PKG}" >> "${HOME}/.gitconfig"
    fi
}

setup_vnc() {
    mkdir -p "${HOME}/.vnc"
    chmod 755 "${HOME}/.vnc"
    cp "${PKG}/vnc/xstartup-xfce" "${HOME}/.vnc/xstartup"
}

setup_browser() {
    local VERSION="$1"
    local arch
    case "${ARCH}" in
        amd64|x86_64)  arch="linux-x86_64" ;;
        arm64|aarch64) arch="linux-aarch64" ;;
        *)             skip "Firefox download not available"; return 0 ;;
    esac

    local URL_BASE="https://download-installer.cdn.mozilla.net/pub/firefox/releases/${VERSION}"
    local URL_FULL="${URL_BASE}/${arch}/en-US/firefox-${VERSION}.tar.xz"

    curl -fsSL -o /tmp/firefox.tar.xz "${URL_FULL}" \
        && tar -xf /tmp/firefox.tar.xz -C "${CPYBIN}" \
        && ln -sf "${CPYBIN}/firefox/firefox" "${CPYBIN}/Firefox" \
        && ln -sf "${CPYBIN}/firefox/firefox" "${HOME}/Desktop/Firefox"
}

setup_speedtest() {
    case "${ARCH}" in
        amd64|x86_64) ;;
        *) skip "Speedtest CLI is x86-only"; return 0 ;;
    esac

    curl -fsSL https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz \
        | tar -xz -C "${CPYBIN}" speedtest
}

setup_ssh() {

    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"

    local gh_user="${GITHUB_USER:-nobody}"
    if ! grep -qF 'github.com' "${HOME}/.ssh/config" 2>/dev/null; then
        printf '\n# Add a key named %s@github.com to ~/.ssh/ for access\n' "${gh_user}" >> "${HOME}/.ssh/config"
        printf 'Host github.com\n    User git\n    IdentityFile ~/.ssh/%s@github.com\n' "${gh_user}" >> "${HOME}/.ssh/config"
    fi
}

setup_prefs() {
    mkdir -p "${HOME}/.config/procps"
    ln -sf "${PKG}/config/procps/toprc" "${HOME}/.config/procps/toprc"
    ln -sf "${PKG}/config/tmux.conf" "${HOME}/.tmux.conf"
    ln -sf "${PKG}/config/vimrc" "${HOME}/.vimrc"

    if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
        git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
    fi

    "${HOME}/.tmux/plugins/tpm/bin/install_plugins"
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

log "DEVTOOLS: Running on-create.sh"

run_step "Persistent storage" setup_persist
run_step "Devtools"           setup_devtools
run_step "Shell"              setup_shell
run_step "Git"                setup_git
run_step "VNC"                setup_vnc
run_step "Browser"            setup_browser "139.0.4"
run_step "Speedtest"          setup_speedtest
run_step "SSH"                setup_ssh
run_step "Preferences"        setup_prefs

log "DEVTOOLS: Completed on-create.sh"

#-------------------------------------------------------------------------------
