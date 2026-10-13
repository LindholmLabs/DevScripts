#!/usr/bin/env bash
_CS_DEFAULT_URL="https://raw.githubusercontent.com/community-scripts/DevScripts/main"
_cs_boot="${COMMUNITY_SCRIPTS_CORE_DIR:-$(dirname "${BASH_SOURCE[0]}")/../../core}/core/build.func"
source "$_cs_boot" 2>/dev/null || source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}/core/build.func")
# Copyright (c) 2021-2026 community-scripts ORG
# Author: William Lindholm (LindholmLabs)
# License: MIT | https://github.com/community-scripts/DevScripts/raw/main/LICENSE
# Source: https://www.factorio.com/

APP="factorio"
var_tags="${var_tags:-appname}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_arm64="${var_arm64:-no}" # Factorio headless is only published for Linux x64.

# Export only app-specific values read by install/appname-install.sh.
# export var_admin_user="${var_admin_user:-}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -x /opt/factorio/bin/x64/factorio ]]; then
    msg_error "No Factorio Installation Found!"
    exit 1
  fi

  msg_info "Stopping Factorio"
  systemctl stop factorio
  msg_ok "Stopped Factorio"

  create_backup /opt/factorio/config /opt/factorio/config-path.cfg \
    /opt/factorio/server-settings.json /opt/factorio/saves /opt/factorio/mods \
    /opt/factorio/player-data.json /opt/factorio/server-adminlist.json \
    /opt/factorio/server-banlist.json /opt/factorio/server-whitelist.json

  # Overlay the release without deleting user files; restore any shipped defaults.
  if ! fetch_and_deploy_from_url "https://factorio.com/get-download/stable/headless/linux64" "/opt/factorio"; then
    restore_backup
    msg_error "Factorio update failed. User data was restored; Factorio remains stopped."
    exit 1
  fi
  restore_backup

  msg_info "Starting Factorio"
  systemctl start factorio
  msg_ok "Started Factorio"
  msg_ok "Updated Factorio successfully!"

  exit
}

start
build_container
description
msg_ok "Completed successfully!\n"
