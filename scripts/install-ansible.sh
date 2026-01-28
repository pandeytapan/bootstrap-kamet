#!/bin/bash
#
# Ansible Installation Script
# Installs Ansible via apt to default system location
#
# Usage: ./install-ansible.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}"
    echo ""
}

log_info()    { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
log_error()   { echo -e "${RED}[✗]${NC} $1"; }
log_step()    { echo -e "${BLUE}[→]${NC} $1"; }

print_header "Ansible Installation"

# Check if already installed
if command -v ansible &> /dev/null; then
    log_warn "Ansible is already installed:"
    echo ""
    ansible --version | head -1
    echo ""
    read -p "Do you want to reinstall/upgrade? [y/N]: " choice
    if [[ ! "$choice" =~ ^[Yy]$ ]]; then
        log_info "Skipping installation."
        exit 0
    fi
fi

# Step 1: Update package lists
log_step "Updating package lists..."
sudo apt update -qq
log_info "Package lists updated"

# Step 2: Install prerequisites
log_step "Installing prerequisites..."
sudo apt install -y -qq software-properties-common python3 python3-pip > /dev/null
log_info "Prerequisites installed"

# Step 3: Add Ansible PPA
log_step "Adding Ansible repository (PPA)..."
sudo add-apt-repository --yes --update ppa:ansible/ansible > /dev/null 2>&1
log_info "Ansible PPA added"

# Step 4: Install Ansible
log_step "Installing Ansible..."
sudo apt install -y -qq ansible > /dev/null
log_info "Ansible installed"

print_header "Installation Complete"

echo -e "${GREEN}Ansible Location:${NC} $(which ansible)"
echo -e "${GREEN}Version:${NC} $(ansible --version | head -1)"
echo ""
echo -e "${YELLOW}Next step:${NC} Run the setup playbook to create directory structure:"
echo ""
echo -e "  ${CYAN}ansible-playbook setup-workspace.yml${NC}"
echo ""
