#!/usr/bin/env bash
# Installs Docker Engine inside the WSL2 Ubuntu distro (not Docker Desktop).
set -euo pipefail

# 1) Make sure systemd is enabled - the docker service needs it.
if ! grep -qs '^\[boot\]' /etc/wsl.conf 2>/dev/null; then
  printf '[boot]\nsystemd=true\n' | sudo tee -a /etc/wsl.conf
  echo ">> systemd enabled. Run 'wsl --shutdown' from Windows PowerShell,"
  echo ">> reopen this distro, then re-run this script."
  exit 0
fi
systemctl is-system-running >/dev/null 2>&1 || {
  echo ">> systemd not running yet. 'wsl --shutdown' from Windows, reopen, retry."; exit 1; }

# 2) Docker's apt repository.
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Docker may lag behind the newest Ubuntu codename; fall back to 'noble'.
CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
if ! curl -fsSo /dev/null "https://download.docker.com/linux/ubuntu/dists/${CODENAME}/Release"; then
  echo ">> No docker repo for '${CODENAME}' yet - falling back to 'noble'."
  CODENAME=noble
fi
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu ${CODENAME} stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"
sudo systemctl enable --now docker

echo ">> Done. Log out/in (or run 'newgrp docker') to use docker without sudo."