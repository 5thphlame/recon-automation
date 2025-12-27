#!/bin/bash
# Complete recon environment setup

echo "=== Setting Up Recon Environment ==="
echo ""

# 1. Install missing Go tools
echo "1. Installing Go tools..."
go install github.com/tomnomnom/httprobe@latest
go install github.com/lc/gau/v2/cmd/gau@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/ffuf/ffuf@latest

# 2. Create directories
echo "2. Creating directories..."
mkdir -p ~/tools
mkdir -p ~/recon/{targets,wordlists,output}

# 3. Update PATH in bashrc if needed
echo "3. Updating PATH..."
if ! grep -q "go/bin" ~/.bashrc; then
    echo 'export PATH="$HOME/go/bin:$HOME/.local/bin:$HOME/tools:$PATH"' >> ~/.bashrc
    echo "  Added to ~/.bashrc"
else
    echo "  PATH already configured"
fi

# 4. Generate tool_paths.conf
echo "4. Generating tool_paths.conf..."
./update_tool_config.sh

# 5. Source bashrc
echo "5. Sourcing ~/.bashrc..."
source ~/.bashrc 2>/dev/null || true

echo ""
echo "=== Setup Complete ==="
echo ""
echo "What to do next:"
echo "1. Copy tool_paths.conf to your USB drive's config/ folder"
echo "2. Add targets to USB/targets/domains.txt"
echo "3. Run: ./recon.sh from your USB drive"
echo ""
echo "Test your setup: ./test_tools.sh"
