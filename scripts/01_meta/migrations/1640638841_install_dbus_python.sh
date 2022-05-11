#!/usr/bin/env bash
set -euo pipefail

# FILENAME_SUFFIX: install_dbus_python
# SUMMARY: If this is a desktop installation, install dbus-python with pip3 as it is required by the spotify widget of bumblebee-status.
# ---
command -v i3 &> /dev/null && pip3 install --user dbus-python
