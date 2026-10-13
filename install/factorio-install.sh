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

msg_info "Installing factorio server"

# download factorio headless server and extract to /opt/factorio
curl -sSL "https://factorio.com/get-download/stable/headless/linux64" -o /tmp/factorio.tar.xz
tar -xJf /tmp/factorio.tar.xz -C /opt

# create new user for factorio
useradd -r -d /opt/factorio -s /bin/false factorio
chown -R factorio:factorio /opt/factorio

msg_info "Creating Factorio Service"
cat <<EOF >/etc/systemd/system/factorio.service
[Unit]
Description=Factorio Headless Server
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=factorio
WorkingDirectory=/opt/factorio_data
ExecStart=/opt/factorio/bin/x64/factorio --config /opt/factorio_data/config.ini --start-server-load-latest --server-settings /opt/factorio_data/server-settings.json --port 34197
KillSignal=SIGINT
TimeoutStopSec=120
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now factorio

msg_ok "Installed factorio server"

motd_ssh
customize
cleanup_lxc