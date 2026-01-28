#!/bin/bash
#
# Upgrade DevTools components
# Usage: sudo ./upgrade.sh [--ansible VERSION]
#

set -e

DEVTOOLS_ROOT="/opt/devtools"
ANSIBLE_VERSION=""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --ansible) ANSIBLE_VERSION="$2"; shift 2 ;;
        --help) 
            echo "Usage: sudo $0 [--ansible VERSION]"
            echo ""
            echo "Options:"
            echo "  --ansible VERSION   Upgrade Ansible to specific version (e.g., 2.17.*)"
            exit 0 
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Check root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo"
    exit 1
fi

echo "=========================================="
echo "  DevTools Upgrade"
echo "=========================================="
echo ""

# Show current versions
log_info "Current Ansible version:"
"${DEVTOOLS_ROOT}/bin/ansible" --version | head -1
echo ""

# Upgrade pip first
log_info "Upgrading pip..."
"${DEVTOOLS_ROOT}/ansible/venv/bin/pip" install --quiet --upgrade pip

# Upgrade Ansible
if [[ -n "$ANSIBLE_VERSION" ]]; then
    log_info "Upgrading Ansible to ${ANSIBLE_VERSION}..."
    "${DEVTOOLS_ROOT}/ansible/venv/bin/pip" install --quiet --upgrade "ansible==${ANSIBLE_VERSION}"
else
    log_info "Upgrading Ansible to latest..."
    "${DEVTOOLS_ROOT}/ansible/venv/bin/pip" install --quiet --upgrade ansible
fi

# Upgrade other tools
log_info "Upgrading ansible-lint..."
"${DEVTOOLS_ROOT}/ansible/venv/bin/pip" install --quiet --upgrade ansible-lint

# Fix ownership
TARGET_USER="${SUDO_USER:-$USER}"
chown -R "${TARGET_USER}:${TARGET_USER}" "${DEVTOOLS_ROOT}"

echo ""
log_info "Upgrade complete!"
echo ""
log_info "New Ansible version:"
"${DEVTOOLS_ROOT}/bin/ansible" --version | head -1
