#!/bin/bash
# ==============================================================================
# 🚀 P2P MESH: Node Bootstrap (Debian 13)
# ==============================================================================
set -e # Exit immediately if a command fails

echo "🛠️  Initializing Mesh Node..."

# 1. INSTALL THE ENGINE
echo "📦 Installing Python, Ansible, and Git..."
sudo apt update && sudo apt install -y python3-apt ansible git-core

# 2. CAPTURE IDENTITY
# This must match a host entry in your inventory/hosts.yml
read -p "❓ Enter Inventory Name (e.g., emil-laptop.local): " INV_NAME

# 3. SEED THE VAULT KEY
# Without this, Ansible cannot decrypt group_vars or private keys
if [ ! -f /etc/ansible/.vault_pass ]; then
    read -sp "🔐 Paste Ansible Vault Password: " VAULT_PASS
    echo
    sudo mkdir -p /etc/ansible
    echo "$VAULT_PASS" | sudo tee /etc/ansible/.vault_pass > /dev/null
    sudo chmod 600 /etc/ansible/.vault_pass
    echo "✅ Vault key seeded to /etc/ansible/.vault_pass"
else
    echo "⏩ Vault key already exists, skipping..."
fi

# 4. CLONE THE REPO
mkdir -p ~/code
mkdir -p ~/code/emildimitrov
if [ ! -d ~/code/emildimitrov/workstations ]; then
    read -sp "🔑 Paste GitHub Personal Access Token: " GIT_TOKEN
    echo
    # Using the token for a one-time authenticated clone
    REPO_URL="https://emildimitrov:${GIT_TOKEN}@github.com/emildimitrov/workstations.git"
    git clone "$REPO_URL" ~/code/emildimitrov/workstations
else
    echo "⏩ Repo already cloned, pulling latest..."
    cd ~/code/emildimitrov/workstations && git pull
fi

# 5. HAND OFF TO ANSIBLE (The "Local Push")
cd ~/code/workstations
echo "🚀 Running initial configuration for $INV_NAME..."

# We use --connection=local because we are running ON the machine we are configuring.
# We use --limit so Ansible applies the specific variables for this host from hosts.yml.
ansible-playbook main.yml \
  --connection=local \
  --inventory inventory/hosts.yml \
  --limit "$INV_NAME" \
  --become-method=sudo

echo "=============================================================================="
echo "✅ BOOTSTRAP COMPLETE!"
echo "💻 $INV_NAME is now a trusted node in the P2P Mesh."
echo "=============================================================================="
