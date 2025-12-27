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

git clone https://github.com/yourusername/recon-automation.git
cd recon-automation

### 2. Setup Environment

chmod +x scripts/*.sh
./scripts/install_missing_tools.sh

### 3. Configure

cp config/tool_paths.conf.example config/tool_paths.conf

NB: Edit config/tool_paths.conf with your system paths

### 4. Run Recon

./scripts/recon.sh

#### 🎯 Use Cases
Bug Bounty Hunting - Automated asset discovery and enumeration

Penetration Testing - Comprehensive reconnaissance phase

Security Assessments - Attack surface mapping

Red Team Operations - Target reconnaissance

Security Research - Automated data gathering

#### 📋 Supported Tools
The suite supports and automatically detects:

Subdomain Enumeration
Assetfinder, Subfinder, Findomain, Amass, Sublist3r, Chaos

Content Discovery
Gobuster, FFuf, Dirsearch, Waybackurls, GAU, Hakrawler

Network Recon
Nmap, Masscan, Httprobe, Httpx, Naabu

OSINT & Intelligence
TheHarvester, Sherlock, Photon, Social-Analyzer

Vulnerability Scanning
Nuclei, Nikto, Dalfox, SQLMap

#### 🔧 Configuration
Tool Paths
Edit config/tool_paths.conf:

#### System tool paths
TOOL_PATHS[python3]="/usr/bin/python3"
TOOL_PATHS[nmap]="/usr/bin/nmap"

#### Go tools
TOOL_PATHS[assetfinder]="$HOME/go/bin/assetfinder"

TOOL_PATHS[subfinder]="$HOME/go/bin/subfinder"

Recon Settings
Edit config/recon.conf:

###### Rate limiting
RATE_LIMIT_DELAY=1
MAX_THREADS=10

###### Scanning options
ENABLE_SUBDOMAIN_ENUM=true
ENABLE_VULN_SCANNING=false

#### 🚀 USB Portable Mode
Run from a USB drive:

###### 1. Copy scripts to USB
cp -r recon-automation /media/usb/

###### 2. Setup USB
cd /media/usb/recon-automation
./scripts/setup_usb.sh

###### 3. Run from anywhere
./scripts/recon.sh

## 📊 Output Structure

output/

└── target.com_20241227_143022/

    ├── asset-discovery/     # Subdomains, IPs
    
    ├── content-discovery/   # URLs, endpoints
    
    ├── fingerprinting/      # Technologies
    
    ├── exploitation/        # Vulnerability testing
    
    ├── handson/            # Manual testing notes
    
    └── reports/            # Findings and summaries
    
## ⚠️ Legal & Ethical Use

⚠️ IMPORTANT: This tool is for authorized security testing only.

Only test systems you own or have explicit permission to test

Respect rate limits and terms of service

Do not use for illegal activities

Comply with all applicable laws and regulations

## 🤝 Contributing

Fork the repository

Create a feature branch (git checkout -b feature/AmazingFeature)

Commit changes (git commit -m 'Add AmazingFeature')

Push to branch (git push origin feature/AmazingFeature)

Open a Pull Request

## 📄 License
Distributed under the MIT License. See LICENSE for more information.

## 🙏 Acknowledgments
Inspired by various bug bounty methodologies

Built upon amazing open-source security tools

Community contributions and feedback

## 📞 Support
Open an Issue

Check Troubleshooting Guide

Review Usage Documentation


## Happy Hunting! 🐛💰
