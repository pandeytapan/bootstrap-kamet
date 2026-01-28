#!/bin/bash
#
# DevTools Bootstrap Script
# Sets up /opt/devtools with Ansible in an isolated virtualenv
#
# Usage: sudo ./bootstrap.sh [--user USERNAME]
#

set -e

# Configuration
DEVTOOLS_ROOT="/opt/devtools"
ANSIBLE_HOME="${DEVTOOLS_ROOT}/ansible"
ANSIBLE_VERSION="2.16.*"  # Pin to major version for stability

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Parse arguments
TARGET_USER="${SUDO_USER:-$USER}"
while [[ $# -gt 0 ]]; do
    case $1 in
        --user) TARGET_USER="$2"; shift 2 ;;
        --help) echo "Usage: sudo $0 [--user USERNAME]"; exit 0 ;;
        *) log_error "Unknown option: $1"; exit 1 ;;
    esac
done

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run with sudo"
    exit 1
fi

echo "=========================================="
echo "  DevTools Bootstrap"
echo "=========================================="
echo ""
log_info "Target user: ${TARGET_USER}"
log_info "DevTools root: ${DEVTOOLS_ROOT}"
echo ""

# Step 1: Install system dependencies
log_info "Installing system dependencies..."
apt-get update -qq
apt-get install -y -qq \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget \
    jq \
    > /dev/null

# Step 2: Create directory structure
log_info "Creating directory structure..."
mkdir -p "${DEVTOOLS_ROOT}"/{ansible,bin,etc,share}
mkdir -p "${DEVTOOLS_ROOT}/etc/ansible"

# Step 3: Create Ansible virtualenv
log_info "Creating Ansible virtualenv..."
python3 -m venv "${ANSIBLE_HOME}/venv"

# Step 4: Install Ansible in virtualenv
log_info "Installing Ansible ${ANSIBLE_VERSION}..."
"${ANSIBLE_HOME}/venv/bin/pip" install --quiet --upgrade pip
"${ANSIBLE_HOME}/venv/bin/pip" install --quiet \
    "ansible==${ANSIBLE_VERSION}" \
    ansible-lint \
    jmespath \
    netaddr

# Step 5: Create wrapper scripts in /opt/devtools/bin
log_info "Creating wrapper scripts..."

# Ansible wrapper
cat > "${DEVTOOLS_ROOT}/bin/ansible" << 'EOF'
#!/bin/bash
exec /opt/devtools/ansible/venv/bin/ansible "$@"
EOF

# Ansible-playbook wrapper
cat > "${DEVTOOLS_ROOT}/bin/ansible-playbook" << 'EOF'
#!/bin/bash
exec /opt/devtools/ansible/venv/bin/ansible-playbook "$@"
EOF

# Ansible-galaxy wrapper
cat > "${DEVTOOLS_ROOT}/bin/ansible-galaxy" << 'EOF'
#!/bin/bash
exec /opt/devtools/ansible/venv/bin/ansible-galaxy "$@"
EOF

# Ansible-lint wrapper
cat > "${DEVTOOLS_ROOT}/bin/ansible-lint" << 'EOF'
#!/bin/bash
exec /opt/devtools/ansible/venv/bin/ansible-lint "$@"
EOF

# Ansible-vault wrapper
cat > "${DEVTOOLS_ROOT}/bin/ansible-vault" << 'EOF'
#!/bin/bash
exec /opt/devtools/ansible/venv/bin/ansible-vault "$@"
EOF

chmod +x "${DEVTOOLS_ROOT}/bin/"*

# Step 6: Create default ansible.cfg
log_info "Creating default Ansible configuration..."
cat > "${DEVTOOLS_ROOT}/etc/ansible/ansible.cfg" << EOF
[defaults]
inventory = ./inventory
roles_path = ./roles:/opt/devtools/share/ansible/roles
collections_path = /opt/devtools/share/ansible/collections
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml
interpreter_python = auto_silent

[privilege_escalation]
become = False
become_method = sudo
become_ask_pass = False

[ssh_connection]
pipelining = True
control_path = /tmp/ansible-%%h-%%p-%%r
EOF

# Step 7: Create shell profile snippet
log_info "Creating shell profile snippet..."
cat > "${DEVTOOLS_ROOT}/etc/devtools.sh" << 'EOF'
# DevTools environment setup
# Source this file in your .bashrc or .zshrc:
#   source /opt/devtools/etc/devtools.sh

export DEVTOOLS_ROOT="/opt/devtools"
export PATH="${DEVTOOLS_ROOT}/bin:${PATH}"
export ANSIBLE_CONFIG="${DEVTOOLS_ROOT}/etc/ansible/ansible.cfg"

# Optional: Ansible-specific aliases
alias ap='ansible-playbook'
alias av='ansible-vault'
alias al='ansible-lint'
EOF

# Step 8: Set ownership
log_info "Setting ownership to ${TARGET_USER}..."
chown -R "${TARGET_USER}:${TARGET_USER}" "${DEVTOOLS_ROOT}"

# Step 9: Verify installation
log_info "Verifying installation..."
ANSIBLE_VER=$("${DEVTOOLS_ROOT}/bin/ansible" --version | head -1)

echo ""
echo "=========================================="
echo "  Installation Complete!"
echo "=========================================="
echo ""
echo "Installed: ${ANSIBLE_VER}"
echo ""
echo "Directory structure:"
echo "  ${DEVTOOLS_ROOT}/"
echo "  ├── ansible/venv/    # Ansible virtualenv"
echo "  ├── bin/             # Wrapper scripts"
echo "  ├── etc/             # Configuration files"
echo "  └── share/           # Shared roles & collections"
echo ""
echo "To activate, add to your ~/.bashrc or ~/.zshrc:"
echo ""
echo "  source /opt/devtools/etc/devtools.sh"
echo ""
echo "Then run: source ~/.bashrc"
echo ""
