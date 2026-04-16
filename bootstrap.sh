#!/bin/bash
# ==============================================================================
# 🚀 P2P MESH: Node Bootstrap (Debian 13)
# ==============================================================================
set -e # Exit immediately if a command fails

echo "🛠️  Initializing Mesh Node..."
sudo apt update

# ==== INSTALL PREREQUISITES ====

# Ansible
if ! command -v ansible-playbook &> /dev/null; then
    echo "Ansible not found. Installing now..."
    sudo apt install -y ansible
else
    echo "Ansible is already installed ($(ansible-playbook --version | head -n 1))"
fi

# Ansible-lint
if ! command -v ansible-lint >/dev/null 2>&1; then
    echo "ansible-lint not found. Installing via apt..."
    sudo apt install -y ansible-lint
else
    echo "ansible-lint is already installed: $(ansible-lint --version)"
fi

# Just
if ! command -v just >/dev/null 2>&1; then
    echo "just not found. Installing via apt..."
    sudo apt install -y just
else
    echo "just is already installed: $(just --version)"
fi

# Git
if ! command -v git &> /dev/null; then
    echo "git not found. Installing now..."
    sudo apt install -y git-core
fi


# === CLONE REPO ===

REPO_DIR="$HOME/code/emildimitrov/workstations"

if [ ! -d "$REPO_DIR" ]; then
    read -p "🔑 Paste GitHub Personal Access Token: " GIT_TOKEN
    echo
    mkdir -p "$(dirname "$REPO_DIR")"
        REPO_URL="https://emildimitrov:${GIT_TOKEN}@github.com/emildimitrov/workstations.git"
        echo "repo is $REPO_URL"
    git clone "$REPO_URL" "$REPO_DIR"

else
    echo "⏩ Repo already cloned, pulling latest..."
    git -C "$REPO_DIR" pull
fi

# === IDENTITY ===

read -p "❓ Enter Inventory Name (e.g., emil-laptop.local): " INV_NAME

# Validate that the name exists in the inventory as a host or group
echo "🔍 Validating '$INV_NAME' against inventory..."
if ! ansible all -i inventory/hosts.yml --limit "$INV_NAME" --list-hosts &>/dev/null; then
    echo "❌ ERROR: '$INV_NAME' does not match any host or group in inventory/hosts.yml"
    echo "Possible hosts: $(ansible all -i inventory/hosts.yml --list-hosts | tail -n +2 | xargs)"
    exit 1
else
    echo "✅ Identity confirmed."
fi


# === VAULT ===

if [ ! -f /etc/ansible/.vault_pass ]; then
    read -p "🔐 Paste Ansible Vault Password: " VAULT_PASS
    echo
    sudo mkdir -p /etc/ansible
    echo "$VAULT_PASS" | sudo tee /etc/ansible/.vault_pass > /dev/null
    sudo chmod 600 /etc/ansible/.vault_pass
    echo "✅ Vault key seeded to /etc/ansible/.vault_pass"
else
    echo "⏩ Vault key already exists, skipping..."
fi

# === EXECUTION ===

cd "$REPO_DIR"

echo "🚀 Launching configuration for: $INV_NAME"

just run-local "$INV_NAME"