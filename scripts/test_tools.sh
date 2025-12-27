#!/bin/bash
# test_tools.sh
# Test if tools are working

echo "=== Testing Installed Tools ==="
echo ""

tools_to_test=(
    "assetfinder"
    "waybackurls"
    "unfurl"
    "python3"
    "curl"
    "nmap"
    "gobuster"
)

for tool in "${tools_to_test[@]}"; do
    echo -n "Testing $tool... "
    
    if command -v "$tool" &> /dev/null; then
        # Get version or help
        if $tool --version &> /dev/null; then
            version=$($tool --version 2>&1 | head -1)
            echo -e "✓ $version"
        elif $tool -h &> /dev/null; then
            echo -e "✓ (help available)"
        else
            echo -e "✓ (installed)"
        fi
    else
        echo -e "✗ NOT FOUND"
    fi
done

echo ""
echo "=== Quick Recon Test ==="
echo "Testing assetfinder with example.com..."
assetfinder example.com 2>/dev/null | head -5

echo ""
echo "Testing waybackurls with example.com..."
echo "example.com" | waybackurls 2>/dev/null | head -3

echo ""
echo "=== PATH Check ==="
echo "Go bin in PATH: $PATH" | grep -q "$HOME/go/bin" && echo "✓ ~/go/bin is in PATH" || echo "✗ ~/go/bin NOT in PATH"
