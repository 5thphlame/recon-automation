#!/bin/bash
## Quick Tool Detector

echo "=== Tool Detector ==="
echo "System: $(uname -s) $(uname -r)"
echo "User: $(whoami)"
echo ""

# Check what's in common directories
echo "Checking ~/go/bin:"
ls -la ~/go/bin/ 2>/dev/null || echo "Directory doesn't exist"

echo ""
echo "Checking ~/.local/bin:"
ls -la ~/.local/bin/ 2>/dev/null || echo "Directory doesn't exist"

echo ""
echo "Checking PATH for common tools:"
tools=("python3" "python" "curl" "wget" "git" "nmap" "gobuster" "assetfinder" "subfinder" "httprobe")

for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo "✓ $tool: $(command -v "$tool")"
    else
        echo "✗ $tool: NOT FOUND"
    fi
done

echo ""
echo "=== Quick Go Tools Check ==="
if command -v go &> /dev/null; then
    echo "Go is installed: $(go version)"
    echo "GOPATH: $GOPATH"
    echo "GOBIN: $GOBIN"
else
    echo "Go is NOT installed"
fi
