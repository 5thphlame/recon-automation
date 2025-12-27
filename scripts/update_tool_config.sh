#!/bin/bash
# update_tool_config.sh
# Update tool_paths.conf with newly installed tools

CONFIG_FILE="tool_paths.conf"
TEMP_FILE="tool_paths.conf.tmp"

echo "Updating $CONFIG_FILE with current tool paths..."
echo ""

# Start with header
cat > "$TEMP_FILE" << 'EOF'
# ============================================================================
# Tool paths configuration for prince@Offsec
# Updated: $(date)
# ============================================================================
EOF

# Go tools section
echo -e "\n# Go tools (from ~/go/bin/)" >> "$TEMP_FILE"

# Find all executables in ~/go/bin
if [ -d "$HOME/go/bin" ]; then
    find "$HOME/go/bin" -maxdepth 1 -type f -executable | while read -r tool; do
        tool_name=$(basename "$tool")
        echo "TOOL_PATHS[$tool_name]=\"$tool\"" >> "$TEMP_FILE"
    done
fi

# System tools section
echo -e "\n# System tools" >> "$TEMP_FILE"

# Common system tools
system_tools=("python3" "python" "curl" "wget" "git" "nmap" "gobuster" "dig" "whois")

for tool in "${system_tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        path=$(command -v "$tool")
        echo "TOOL_PATHS[$tool]=\"$path\"" >> "$TEMP_FILE"
    fi
done

# Check for subfinder (you have it in /usr/bin/)
if command -v subfinder &> /dev/null; then
    echo "TOOL_PATHS[subfinder]=\"$(command -v subfinder)\"" >> "$TEMP_FILE"
fi

# Arsenal (from your ~/.local/bin/)
if [ -L "$HOME/.local/bin/arsenal" ]; then
    echo -e "\n# Arsenal CLI" >> "$TEMP_FILE"
    echo "TOOL_PATHS[arsenal]=\"$HOME/.local/bin/arsenal\"" >> "$TEMP_FILE"
fi

# Add installation notes
cat >> "$TEMP_FILE" << 'EOF'

# ============================================================================
# INSTALLATION NOTES
# ============================================================================
# Missing but useful tools:
# - findomain: Fast subdomain enumeration
#   wget https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux -O ~/tools/findomain
#
# - amass: In-depth attack surface mapping
#   go install github.com/owasp-amass/amass/v3/...@master
#
# - bbot: Modern OSINT framework
#   pipx install bbot
#
# Wordlists location:
# COMMON_WORDLIST="/usr/share/wordlists/dirb/common.txt"
# SECLISTS_DIR="/usr/share/seclists"
EOF

# Replace old file
mv "$TEMP_FILE" "$CONFIG_FILE"

echo "Updated $CONFIG_FILE"
echo ""
echo "Current tools detected:"
echo "======================"

# Show what we found
echo "Go tools in ~/go/bin/:"
ls -1 ~/go/bin/ 2>/dev/null || echo "  (none)"

echo ""
echo "System tools:"
for tool in python3 curl nmap gobuster; do
    if command -v "$tool" &> /dev/null; then
        echo "  ✓ $tool"
    fi
done
