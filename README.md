# Ansible Playbooks Collection

A comprehensive collection of Ansible playbooks for managing your Pop!_OS 20.04 development workstation.

---

## 📁 Directory Structure

```
~/Documents/books/
├── ansible.cfg              # Ansible configuration
├── .env                     # Shell environment (PATH, aliases)
├── .dev-env                 # Development environment additions
├── inventory/
│   └── hosts.ini            # Inventory file
│
├── conf.books/              # System Configuration
│   ├── safe-upgrade.yml     ✅ PROVIDED
│   ├── health-check.yml     ✅ PROVIDED
│   ├── system-config.ini    ✅ PROVIDED
│   ├── backup-system.yml    📋 RECOMMENDED
│   └── setup-grub.yml       📋 RECOMMENDED
│
├── code.books/              # Development Environment
│   ├── setup-dev-env.yml    ✅ PROVIDED
│   ├── setup-python-project.yml  📋 RECOMMENDED
│   ├── setup-cpp-project.yml     📋 RECOMMENDED
│   ├── setup-vscode.yml     📋 RECOMMENDED
│   └── setup-neovim.yml     📋 RECOMMENDED
│
├── personal.books/          # Personal Setup
│   ├── dotfiles.yml         📋 RECOMMENDED
│   ├── install-apps.yml     📋 RECOMMENDED
│   ├── setup-ssh-keys.yml   📋 RECOMMENDED
│   └── setup-git.yml        📋 RECOMMENDED
│
├── office.books/            # Work Automation
│   ├── setup-vpn.yml        📋 RECOMMENDED
│   └── setup-work-tools.yml 📋 RECOMMENDED
│
├── client.books/            # Client Projects
│   └── (your client-specific playbooks)
│
└── tmp.books/               # Experiments
    └── example.yml          ✅ PROVIDED
```

---

## ✅ Provided Playbooks

### 1. Setup Scripts (Run Once)

#### `install-ansible.sh` (Bash Script)
**Purpose:** Install Ansible via apt to default system location

**Usage:**
```bash
chmod +x install-ansible.sh
./install-ansible.sh
```

**What it does:**
- Updates package lists
- Adds Ansible PPA
- Installs Ansible
- Verifies installation

---

#### `setup-workspace.yml`
**Purpose:** Create the entire `~/Documents/books/` directory structure

**Usage:**
```bash
ansible-playbook setup-workspace.yml
```

**What it creates:**
- `/opt/devtools/` structure (bin, src, share, etc)
- `~/Documents/books/` with all `.books/` subdirectories
- `ansible.cfg` configuration
- `inventory/hosts.ini`
- `.env` file with aliases
- Updates `~/.bashrc` automatically

**Aliases configured:**
| Alias | Command |
|-------|---------|
| `ab` | `cd ~/Documents/books` |
| `ap` | `ansible-playbook` |
| `al` | `ansible-lint` |
| `av` | `ansible-vault` |

---

### 2. System Configuration (`conf.books/`)

#### `conf.books/safe-upgrade.yml`
**Purpose:** Safely upgrade system while protecting NVIDIA drivers and kernel

**Usage:**
```bash
# Dry run (check what will happen)
ap conf.books/safe-upgrade.yml

# Actually upgrade
ap conf.books/safe-upgrade.yml -e upgrade=true
```

**What it does:**
1. Gathers current system state
2. Creates backup in `conf.books/backups/`
3. Holds (protects) ALL NVIDIA packages including i386
4. Holds current kernel packages
5. Checks available updates
6. Performs safe upgrade (apt upgrade, not full-upgrade)
7. Verifies NVIDIA still works

**Protected packages:**
- `nvidia-*` (all NVIDIA packages)
- `linux-image-<current-kernel>`
- `linux-headers-<current-kernel>`

---

#### `conf.books/health-check.yml`
**Purpose:** Monitor system health, disk space, NVIDIA status, and more

**Usage:**
```bash
ap conf.books/health-check.yml
```

**What it checks:**
| Check | Warning Threshold |
|-------|-------------------|
| Memory usage | > 80% |
| Disk usage | > 80% |
| NVIDIA driver | Not responding |
| Held packages | None protected |
| Pending updates | Any available |
| Critical services | SSH, NetworkManager, systemd-resolved |

**Output includes:**
- System information (OS, kernel, hostname, uptime)
- CPU & memory status
- Disk space usage
- NVIDIA GPU status (driver, temp, utilization)
- Protected packages list
- Pending updates count
- Services status
- Health summary

---

#### `conf.books/system-config.ini`
**Purpose:** Reference file documenting your current system state

**Contents:**
```ini
[system]
os_name = Pop!_OS
os_version = 20.04 LTS
kernel = 5.16.15-76051615-generic

[nvidia]
driver_version = 510.54
cuda_version = 11.6
gpu_model = NVIDIA GeForce GTX 1650 (4GB)

[packages_to_hold]
nvidia-dkms-510
nvidia-driver-510
linux-headers-5.16.15-76051615-generic
linux-image-5.16.15-76051615-generic
```

---

### 3. Development Environment (`code.books/`)

#### `code.books/setup-dev-env.yml`
**Purpose:** Install comprehensive C++ and Python development tools

**Usage:**
```bash
# Dry run
ap code.books/setup-dev-env.yml

# Install
ap code.books/setup-dev-env.yml -e install=true

# With optional components
ap code.books/setup-dev-env.yml -e install=true -e install_docker=true -e install_rust=true
```

**What it installs:**

| Category | Tools |
|----------|-------|
| **System Essentials** | build-essential, git, curl, wget, htop, tmux, ripgrep, fd-find |
| **C++ Compilers** | gcc, g++, clang, clang-format, clang-tidy, clangd |
| **C++ Build** | cmake, ninja, meson, ccache |
| **C++ Debug** | gdb, valgrind, strace, ltrace, cppcheck |
| **C++ Libraries** | boost, eigen, gtest, benchmark |
| **Python Runtime** | python3, pip, venv, pyenv |
| **Python Linting** | ruff, black, mypy, isort |
| **Python Testing** | pytest, pytest-cov, pytest-xdist |
| **Python REPL** | ipython, ipdb, rich, jupyter |
| **ML/AI Stack** | numpy, scipy, pandas, matplotlib, scikit-learn, pytorch (CPU) |
| **Editors** | vim, neovim, clangd (LSP), python-lsp-server |

**Optional components:**
| Flag | Installs |
|------|----------|
| `-e install_docker=true` | Docker CE, docker-compose |
| `-e install_rust=true` | Rust via rustup |
| `-e install_nodejs=true` | Node.js |

**Aliases added:**
| Alias | Command |
|-------|---------|
| `py` | `python3` |
| `ipy` | `ipython` |
| `venv` | `python3 -m venv` |
| `activate` | `source venv/bin/activate` |
| `cmakeb` | `cmake -B build -G Ninja` |
| `cmaker` | `cmake --build build` |

---

## 📋 Recommended Playbooks (To Be Created)

### System Configuration (`conf.books/`)

#### `backup-system.yml`
**Purpose:** Backup dotfiles, configs, and important data to git repo

**Would do:**
- Backup `~/.bashrc`, `~/.gitconfig`, `~/.ssh/config`
- Backup `~/Documents/books/` configs
- Backup VS Code settings
- Commit to a git repository
- Optional: push to GitHub

---

#### `setup-grub.yml`
**Purpose:** Switch from systemd-boot to GRUB with themes

**Would do:**
- Install grub-efi-amd64
- Configure GRUB for dual-boot
- Install a nice theme (Vimix, Sleek, etc.)
- Auto-detect Windows
- Set timeout and default OS

---

### Development (`code.books/`)

#### `setup-python-project.yml`
**Purpose:** Create a new Python project with best practices

**Would create:**
```
my-project/
├── src/
│   └── my_project/
│       └── __init__.py
├── tests/
│   └── test_main.py
├── pyproject.toml
├── README.md
├── .gitignore
├── .pre-commit-config.yaml
└── Makefile
```

---

#### `setup-cpp-project.yml`
**Purpose:** Create a new C++ project with CMake + Ninja

**Would create:**
```
my-project/
├── src/
│   └── main.cpp
├── include/
│   └── my_project/
├── tests/
│   └── test_main.cpp
├── CMakeLists.txt
├── README.md
├── .gitignore
├── .clang-format
└── .clang-tidy
```

---

#### `setup-vscode.yml`
**Purpose:** Configure VS Code with extensions and settings

**Would install extensions:**
- C/C++ (Microsoft)
- Python (Microsoft)
- clangd
- CMake Tools
- GitLens
- Error Lens
- Prettier

---

#### `setup-neovim.yml`
**Purpose:** Configure Neovim for development

**Would setup:**
- lazy.nvim package manager
- LSP support (clangd, pyright)
- Treesitter
- Telescope
- Which-key
- Auto-completion

---

### Personal Setup (`personal.books/`)

#### `dotfiles.yml`
**Purpose:** Backup and restore dotfiles

**Would manage:**
- `~/.bashrc`
- `~/.gitconfig`
- `~/.tmux.conf`
- `~/.vimrc` / Neovim config
- `~/.ssh/config`

---

#### `install-apps.yml`
**Purpose:** Install personal applications

**Would install:**
- Browsers (Firefox, Chrome)
- Media (VLC, Spotify)
- Communication (Slack, Discord)
- Utilities (Flameshot, Peek)

---

#### `setup-ssh-keys.yml`
**Purpose:** Generate and configure SSH keys

**Would do:**
- Generate ed25519 SSH key
- Configure `~/.ssh/config`
- Add key to ssh-agent
- Display public key for GitHub/GitLab

---

#### `setup-git.yml`
**Purpose:** Configure git globally

**Would setup:**
- User name and email
- Default branch name
- Useful aliases (st, co, br, lg)
- GPG signing (optional)
- Credential helper

---

### Office/Work (`office.books/`)

#### `setup-vpn.yml`
**Purpose:** Configure VPN connection

**Would do:**
- Install OpenVPN/WireGuard
- Import VPN configuration
- Setup auto-connect

---

#### `setup-work-tools.yml`
**Purpose:** Install work-specific tools

**Would install:**
- Jira CLI
- AWS CLI
- kubectl
- Terraform
- Other work tools

---

## 🚀 Quick Reference

### Daily Commands

```bash
# Jump to playbooks directory
ab

# Check system health
ap conf.books/health-check.yml

# Safe system upgrade
ap conf.books/safe-upgrade.yml -e upgrade=true
```

### First-Time Setup

```bash
# 1. Install Ansible
./install-ansible.sh

# 2. Create workspace
ansible-playbook setup-workspace.yml

# 3. Reload shell
source ~/.bashrc

# 4. Install dev tools
ab
ap code.books/setup-dev-env.yml -e install=true
```

### Flags Reference

| Flag | Purpose |
|------|---------|
| `-e install=true` | Actually install (vs dry run) |
| `-e upgrade=true` | Actually upgrade (vs dry run) |
| `-e install_docker=true` | Include Docker |
| `-e install_rust=true` | Include Rust |
| `--check` | Ansible dry run mode |
| `-v` | Verbose output |
| `-vvv` | Very verbose output |

---

## 📝 Notes

### Your System Configuration

| Component | Value |
|-----------|-------|
| OS | Pop!_OS 20.04 LTS |
| Kernel | 5.16.15-76051615-generic |
| NVIDIA Driver | 510.54 |
| CUDA | 11.6 |
| GPU | NVIDIA GeForce GTX 1650 (4GB) |

### Important Reminders

1. **Always run dry run first** - Check what will happen before applying
2. **NVIDIA packages are held** - Won't upgrade accidentally
3. **Kernel is held** - Won't upgrade accidentally
4. **Backup before major changes** - Use `health-check.yml` regularly
5. **GPU PyTorch** - Install separately with CUDA support:
   ```bash
   pip install torch torchvision --index-url https://download.pytorch.org/whl/cu116
   ```

---

## 🤝 Contributing

To add a new playbook:

1. Create in appropriate `.books/` directory
2. Follow naming convention: `action-target.yml`
3. Include header with usage instructions
4. Use colored output for visibility
5. Default to dry-run mode with `-e flag=true` for execution

---

*Last updated: January 2026*
