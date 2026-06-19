#!/usr/bin/env bash
set -euo pipefail

export USER="${USER:-testuser}"
export HOME="${HOME:-/home/testuser}"
export DISPLAY="${DISPLAY:-:1}"

vnc_geometry="${VNC_GEOMETRY:-1440x900}"
vnc_depth="${VNC_DEPTH:-24}"
vnc_password="${VNC_PASSWORD:-dotfiles}"

if ! command -v vncserver >/dev/null 2>&1; then
    cat >&2 <<'EOF'
VNC is not installed in this image.
Build the GUI test image with DOTFILES_MACHINE_TYPE=gui.
EOF
    exit 1
fi

mkdir -p "${HOME}/.vnc"
if [[ ! -f "${HOME}/.vnc/passwd" ]]; then
    printf '%s\n' "${vnc_password}" | vncpasswd -f > "${HOME}/.vnc/passwd"
    chmod 600 "${HOME}/.vnc/passwd"
fi

cat > "${HOME}/.vnc/xstartup" <<'EOF'
#!/usr/bin/env bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

xrdb "${HOME}/.Xresources" 2>/dev/null || true

if command -v i3 >/dev/null 2>&1; then
    if command -v dbus-run-session >/dev/null 2>&1; then
        exec dbus-run-session -- i3
    fi
    exec i3
fi

exec xterm
EOF
chmod +x "${HOME}/.vnc/xstartup"

vncserver -kill "${DISPLAY}" >/dev/null 2>&1 || true
exec vncserver "${DISPLAY}" -fg -geometry "${vnc_geometry}" -depth "${vnc_depth}" -localhost no
