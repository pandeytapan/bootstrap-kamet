#!/bin/bash
#
# DevTools Bootstrap - One Command Setup
# 
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/pandeytapan/bootstrap-kamet/main/setup.sh | bash -s -- -y
#
# Or clone and run:
#   git clone https://github.com/pandeytapanbootstrap-kamet.git
#   cd bootstrap-kamet
#   ./setup.sh
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
    echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}\n"
}

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_step()  { echo -e "${BLUE}[→]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# Configuration
REPO_URL="https://github.com/pandeytapan/bootstrap-kamet.git"
BOOTSTRAP_DIR="$HOME/.bootkamet/bootstrap-kamet"
BOOKS_DIR="$HOME/Documents/books"

# Parse arguments
AUTO_YES=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes) AUTO_YES=true; shift ;;
        *) shift ;;
    esac
done

# Detect if running from pipe
if [ ! -t 0 ]; then
    AUTO_YES=true
fi

print_header "Bootstrap Kamet"

echo -e "${BOLD}This script will:${NC}"
echo -e "  1. Install Ansible"
echo -e "  2. Create workspace structure"
echo -e "  3. Copy playbooks to ~/Documents/books/"
echo -e "  4. Configure shell environment"
echo -e ""

if [ "$AUTO_YES" = false ]; then
    read -p "Continue? [Y/n]: " choice
    if [[ "$choice" =~ ^[Nn]$ ]]; then
        echo "Aborted."
        exit 0
    fi
else
    echo -e "${YELLOW}[!] Running in non-interactive mode${NC}\n"
fi

# ══════════════════════════════════════════
# STEP 1: Clone or update repo
# ══════════════════════════════════════════
print_header "Step 1/5: Getting Kamet Bootstrap Code"

if [ -d "$BOOTSTRAP_DIR" ]; then
    log_info "Bootstrap code exists, updating..."
    cd "$BOOTSTRAP_DIR"
    git pull --quiet
else
    log_step "Cloning repository..."
    mkdir -p "$BOOTSTRAP_DIR"
    git clone --quiet "$REPO_URL" "$BOOTSTRAP_DIR"
    cd "$BOOTSTRAP_DIR"
fi
log_info "Bootstrap repo ready at $BOOTSTRAP_DIR"

# ══════════════════════════════════════════
# STEP 2: Install Ansible
# ══════════════════════════════════════════
print_header "Step 2/5: Installing Ansible"

if command -v ansible &> /dev/null; then
    log_info "Ansible already installed: $(ansible --version | head -1)"
else
    log_step "Installing Ansible..."
    sudo apt update -qq
    sudo apt install -y -qq software-properties-common > /dev/null
    sudo add-apt-repository --yes --update ppa:ansible/ansible > /dev/null 2>&1
    sudo apt install -y -qq ansible > /dev/null
    log_info "Ansible installed: $(ansible --version | head -1)"
fi

# ══════════════════════════════════════════
# STEP 3: Run workspace setup playbook
# ══════════════════════════════════════════
print_header "Step 3/5: Creating Workspace Structure"

log_step "Running setup-workspace.yml..."
ansible-playbook "$BOOTSTRAP_DIR/setup-workspace.yml" --ask-become-pass
log_info "Workspace created at $BOOKS_DIR"

# ══════════════════════════════════════════
# STEP 4: Copy playbooks
# ══════════════════════════════════════════
print_header "Step 4/5: Installing Playbooks"

log_step "Copying playbooks..."

# Copy conf playbooks
cp "$BOOTSTRAP_DIR/playbooks/conf/"*.yml "$BOOKS_DIR/conf.books/" 2>/dev/null || true
cp "$BOOTSTRAP_DIR/playbooks/conf/"*.ini "$BOOKS_DIR/conf.books/" 2>/dev/null || true
log_info "Copied conf.books/ playbooks"

# Copy code playbooks
cp "$BOOTSTRAP_DIR/playbooks/code/"*.yml "$BOOKS_DIR/code.books/" 2>/dev/null || true
log_info "Copied code.books/ playbooks"

# Copy personal playbooks
cp "$BOOTSTRAP_DIR/playbooks/personal/"*.yml "$BOOKS_DIR/personal.books/" 2>/dev/null || true
log_info "Copied personal.books/ playbooks"

# Copy office playbooks
cp "$BOOTSTRAP_DIR/playbooks/office/"*.yml "$BOOKS_DIR/office.books/" 2>/dev/null || true
log_info "Copied office.books/ playbooks"

# ══════════════════════════════════════════
# STEP 5: Reload shell
# ══════════════════════════════════════════
print_header "Step 5/5: Finalizing"

log_info "Setup complete!"

echo -e ""
echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  Setup Complete!${NC}"
echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}"
echo -e ""
echo -e "${BOLD}Directory structure:${NC}"
echo -e "  ${YELLOW}$BOOKS_DIR/${NC}"
echo -e "  ├── conf.books/      # System configuration"
echo -e "  ├── code.books/      # Development setup"
echo -e "  ├── personal.books/  # Personal configuration"
echo -e "  ├── office.books/    # Work automation"
echo -e "  └── tmp.books/       # Experiments"
echo -e ""
echo -e "${BOLD}Next steps:${NC}"
echo -e ""
echo -e "  1. ${CYAN}source ~/.bashrc${NC}"
echo -e "  2. ${CYAN}ab${NC}  # Jump to books directory"
echo -e "  3. ${CYAN}ap conf.books/health-check.yml${NC}  # Check system"
echo -e "  4. ${CYAN}ap code.books/setup-dev-env.yml -e install=true${NC}  # Install dev tools"
