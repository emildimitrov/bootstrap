# 💻 Workstation Provisioning Guide (Debian 13)

Follow these steps to prepare a new machine for the **P2P Mesh**. This guide ensures the hardware is ready for the `bootstrap.sh` script to take over.

---

## 1. Operating System Installation

* **Version**: Install **Debian 13 (Trixie)** or the latest stable release.
* **User Account**: Create the primary user (e.g., `emil`, `iva`, or `ema`).
  * **Crucial**: Leave the **Root Password BLANK** during the installer. This forces Debian to install `sudo` and add your user to the `sudoers` group automatically.
* **Hostname**: Set any temporary hostname (e.g., `debian-temp`). The Ansible `host` role will overwrite this with the correct mesh identity later.
* **Software Selection**: Ensure **SSH Server** and your preferred Desktop Environment (GNOME/KDE) are selected.

---

## 2. Prerequisite Secrets

Before running the setup, ensure you have the following credentials ready (e.g., from **Bitwarden**):

* **Ansible Vault Pass**: Required to decrypt host-specific SSH keys and system variables.
* **GitHub Read-Only Token**: A Personal Access Token (PAT) with `repo` read permissions to clone the private `workstations` repository.

---

## 3. Automated Onboarding

Once logged into the new machine,

Get the bootstrap.sh from here

open a terminal and run the bootstrap process:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

## 4. Post-Setup Verification

After the script finishes and the first `ansible-playbook` run completes:

* **Reboot**: To apply the new hostname and kernel parameters.
* **Test Mesh Connectivity**:
  * `ping $(hostname).local` — Ensure mDNS is broadcasting.
  * `ssh other-node.local` — Test Mesh SSH Key trust.
* **Check Firewall**:
  * `sudo nft list ruleset` — Ensure the mesh rules are active.
