#!/bin/bash
# Setup script for USB recon drive

echo "=== USB Recon Drive Setup ==="
echo ""

# Get USB directory
USB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "USB Directory: $USB_DIR"
echo ""

# Create directory structure
echo "Creating directories..."
mkdir -p "$USB_DIR/config"
mkdir -p "$USB_DIR/targets"
mkdir -p "$USB_DIR/wordlists"
mkdir -p "$USB_DIR/output"

# Create sample files
echo "Creating sample files..."

# Sample targets
cat > "$USB_DIR/targets/domains.txt" << EOF
# Add target domains here (one per line)
# example.com
# target.org
# test.com
EOF

# Sample wordlist info
cat > "$USB_DIR/wordlists/README.md" << EOF
# Wordlists
Copy wordlists from your system to this directory:
- common.txt (from /usr/share/wordlists/dirb/)
- subdomains.txt
- big.txt
Or download from:
- https://github.com/danielmiessler/SecLists
EOF

# Create config files if they don't exist
if [ ! -f "$USB_DIR/config/recon.conf" ]; then
    echo "Creating default config..."
    cat > "$USB_DIR/config/recon.conf" << 'EOF'
# Recon Script Configuration
RATE_LIMIT_DELAY=1
BATCH_DELAY=3
MAX_THREADS=10
ENABLE_RATE_LIMIT=true
COMPRESS_RESULTS=true
EOF
fi

if [ ! -f "$USB_DIR/config/tool_paths.conf" ]; then
    echo "Creating tool paths template..."
    cat > "$USB_DIR/config/tool_paths.conf" << 'EOF'
# Update these paths for YOUR system
# TOOL_PATHS[assetfinder]="$HOME/go/bin/assetfinder"
# TOOL_PATHS[subfinder]="$HOME/go/bin/subfinder"
# ... etc
EOF
    echo "Please edit $USB_DIR/config/tool_paths.conf with your system paths"
fi

# Make scripts executable
chmod +x "$USB_DIR/recon.sh" 2>/dev/null
chmod +x "$USB_DIR/setup_usb.sh" 2>/dev/null

echo ""
echo "=== Setup Complete ==="
echo "Next steps:"
echo "1. Edit $USB_DIR/config/tool_paths.conf with your system tool paths"
echo "2. Add targets to $USB_DIR/targets/domains.txt"
echo "3. Copy wordlists to $USB_DIR/wordlists/"
echo "4. Run: ./recon.sh"
