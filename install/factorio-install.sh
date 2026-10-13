#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: William Lindholm (LindholmLabs)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://www.factorio.com/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing App Name"
# App-specific dependencies, deployment, configuration, and service setup.
msg_ok "Installed App Name"

motd_ssh
customize
cleanup_lxc