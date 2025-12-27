# 🔍 Recon Automation Suite

A comprehensive, portable reconnaissance automation toolkit for bug bounty hunters and penetration testers.

![GitHub](https://img.shields.io/badge/License-MIT-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20WSL-green)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

## 🚀 Features

- **🔄 Automated Reconnaissance** - Full pipeline from subdomain enumeration to vulnerability discovery
- **💾 USB Portable** - Run from USB drive with system-installed tools
- **🔧 Auto Tool Detection** - Automatically finds installed security tools
- **⚡ Rate Limiting** - Respectful scanning with configurable delays
- **📊 Organized Output** - Clean, timestamped directory structure
- **🔒 Secure Config** - No hardcoded API keys or credentials
- **📈 Comprehensive Reporting** - Detailed summaries and findings

## 📁 Repository Structure
recon-automation/

├── scripts/ # Main automation scripts

├── config/ # Configuration templates

├── templates/ # Input file templates

├── docs/ # Documentation

└── utils/ # Utility functions


## 🛠️ Main Scripts

| Script | Purpose | Dependencies |
|--------|---------|-------------|
| [`recon.sh`](scripts/recon.sh) | Main reconnaissance automation | Python3, Go tools, curl |
| [`detect_tools.sh`](scripts/detect_tools.sh) | Detect installed security tools | Bash |
| [`install_missing_tools.sh`](scripts/install_missing_tools.sh) | Install missing recon tools | Go, pip |
| [`update_tool_config.sh`](scripts/update_tool_config.sh) | Update tool configuration | Bash |
| [`test_tools.sh`](scripts/test_tools.sh) | Test installed tools | Bash |
| [`setup_usb.sh`](scripts/setup_usb.sh) | Setup USB drive for portable use | Bash |

## ⚡ Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/recon-automation.git
cd recon-automation
