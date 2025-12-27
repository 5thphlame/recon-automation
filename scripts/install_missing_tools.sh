#!/bin/bash
# install_missing_tools.sh
# Install missing recon tools for prince@Offsec

echo "=== Installing Missing Recon Tools ==="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Go installation
if ! command -v go &> /dev/null; then
    echo -e "${RED}[!] Go is not installed${NC}"
    echo "Install Go first: sudo apt install golang"
    exit 1
fi

echo -e "${GREEN}[+] Go is installed: $(go version)${NC}"
echo ""

# Tools to install
declare -A tools=(
    ["httprobe"]="github.com/tomnomnom/httprobe@latest"
    ["gau"]="github.com/lc/gau/v2/cmd/gau@latest"
    ["httpx"]="github.com/projectdiscovery/httpx/cmd/httpx@latest"
    ["ffuf"]="github.com/ffuf/ffuf@latest"
    ["nuclei"]="github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
    ["katana"]="github.com/projectdiscovery/katana/cmd/katana@latest"
    ["naabu"]="github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
    ["dnsx"]="github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
    ["notify"]="github.com/projectdiscovery/notify/cmd/notify@latest"
)

echo "Installing Go tools to ~/go/bin/"
echo "================================="

for tool in "${!tools[@]}"; do
    echo -n "Installing $tool... "
    
    # Check if already installed
    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}Already installed${NC}"
        continue
    fi
    
    # Install the tool
    if go install "${tools[$tool]}" 2>/dev/null; then
        echo -e "${GREEN}Success${NC}"
    else
        echo -e "${RED}Failed${NC}"
    fi
done

echo ""
echo "Installing Python tools"
echo "======================="

# Python tools
pip_tools=("sublist3r" "theHarvester" "dirsearch")

for tool in "${pip_tools[@]}"; do
    echo -n "Checking $tool... "
    if pip list | grep -i "$tool" &> /dev/null; then
        echo -e "${GREEN}Already installed${NC}"
    else
        echo -e "${YELLOW}Not installed (run: pip install $tool)${NC}"
    fi
done

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Tools installed in: ~/go/bin/"
echo "Add to PATH if not already:"
echo '  export PATH="$HOME/go/bin:$PATH"'
echo ""
echo "To update your tool_paths.conf, run:"
echo "  ./update_tool_config.sh"
