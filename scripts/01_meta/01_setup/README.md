# Dotfiles Setup

This directory contains the machine bootstrap for this dotfiles repository.

## Fresh machine

Clone the repository to `~/.dotfiles`, then run:

```sh
~/.dotfiles/scripts/01_meta/01_setup/bootstrap.sh
```

Run `~/.dotfiles/scripts/01_meta/01_setup/bootstrap.sh -h` for all flags and
partial-run examples.

The bootstrap installs `uv` first and runs Ansible through `uvx`, so Ansible is
not installed as a persistent prerequisite. The bootstrap path itself only needs
`curl` and the already-cloned repository; `git` is also needed by the playbook's
repository checkout tasks.

## Machine types

- `headless` is the default and installs the baseline CLI environment without GUI packages.
- `gui` installs the baseline CLI environment plus GUI package groups.

Use flags to adjust the selected features:

```sh
bootstrap.sh --headless --no-heavy-dev
bootstrap.sh --gui --wayland --work
bootstrap.sh --gui --no-heavy-dev
```

Relevant environment variables:

- `DOTFILES_MACHINE_TYPE`: `gui` or `headless`
- `DOTFILES_INSTALL_WORK`: install work-specific packages
- `DOTFILES_INSTALL_WAYLAND`: install Wayland-specific packages
- `DOTFILES_INSTALL_HEAVY_DEV`: install Rust, Go, and the Miniforge dev environment
- `DOTFILES_INSTALL_VARIOUS`: install miscellaneous optional tools
- `DOTFILES_ALLOW_SUDO`: allow system package installation
- `DOTFILES_NODE_LTS_MAJOR`: choose the Node LTS major version

Node (via nvm) and uv are always installed. GUI machines install the configured
Flatpak apps for the enabled package groups.

## Tests

Run the Ubuntu test matrix with:

```sh
./scripts/01_meta/01_setup/test.sh
```

Set `DOTFILES_TEST_ALL_DISTROS=true` to also run best-effort Fedora, Arch, and
Alpine containers.

The Ubuntu GUI image includes VNC support for manual inspection:

```sh
./scripts/01_meta/01_setup/test.sh
docker run --rm -it -p 5901:5901 dotfiles.ubuntu-gui \
    /home/testuser/.dotfiles/scripts/01_meta/01_setup/tests/start-vnc.sh
```

Then connect a VNC client to `localhost:5901`. The default password is
`dotfiles`; override it with `-e VNC_PASSWORD=...` when running the container.
