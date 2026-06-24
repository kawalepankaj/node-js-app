#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "Please run this script with sudo or as root: sudo ./setup-ubuntu.sh"
  exit 1
fi

echo "Updating apt packages..."
apt update

echo "Installing prerequisites..."
apt install -y ca-certificates curl gnupg lsb-release software-properties-common gettext-base

echo "Installing Docker..."
apt install -y docker.io
systemctl enable --now docker

echo "Installing Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

if ! command -v kubectl >/dev/null 2>&1; then
  echo "Installing kubectl..."
  curl -fsSLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
fi

if [ -n "${SUDO_USER:-}" ]; then
  echo "Adding $SUDO_USER to docker group..."
  usermod -aG docker "$SUDO_USER"
fi

echo "Verifying installation..."
node -v
npm -v
docker --version
kubectl version --client --short
envsubst --version

echo
cat <<'EOF'
Ubuntu setup is complete.
If you added your user to the docker group, log out and back in or run:
  newgrp docker
EOF
