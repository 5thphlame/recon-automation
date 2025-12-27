#!/bin/bash
## ============================================================================
## USB Drive Recon Script
## Modified: $(date)
## Features:
## - USB portable (tools on system, output on USB)
## - Secure API key handling
## - Rate limiting
## - Error handling
## - Organized output structure
## ============================================================================

set -e  # Exit on error

# ============================================================================
# CONFIGURATION & INITIALIZATION
# ============================================================================

# ANSI Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Banner
echo -e "${CYAN}"
cat << "EOF"
░▒▓   │   ~ ▓▒░ RECON SCRIPT ░▒▓ │ at $(date +%H:%M:%S)   ▓▒░
================================================================
EOF
echo -e "${NC}"

# Get USB drive location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "$0")"

# Detect if running from USB
detect_usb() {
    MOUNT_POINT=$(df "$SCRIPT_DIR" 2>/dev/null | tail -1 | awk '{print $6}')
    if [[ "$MOUNT_POINT" =~ ^/(media|mnt|run/media|Volumes)/ ]]; then
        echo -e "${GREEN}[+] Running from USB drive: $MOUNT_POINT${NC}"
        USB_MODE=true
    else
        echo -e "${YELLOW}[+] Running from local system${NC}"
        USB_MODE=false
    fi
}
detect_usb

# ============================================================================
# PATHS & DIRECTORIES
# ============================================================================

# Base directories
USB_BASE="$SCRIPT_DIR"
CONFIG_DIR="${USB_BASE}/config"
TARGETS_DIR="${USB_BASE}/targets"
WORDLISTS_DIR="${USB_BASE}/wordlists"
OUTPUT_BASE="${USB_BASE}/output"

# Create directory structure
create_directories() {
    echo -e "${BLUE}[+] Creating directory structure...${NC}"
    
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$TARGETS_DIR"
    mkdir -p "$WORDLISTS_DIR"
    mkdir -p "$OUTPUT_BASE"
    
    # Wordlists (copy if missing)
    if [ ! -f "${WORDLISTS_DIR}/common.txt" ]; then
        echo -e "${YELLOW}[!] No wordlists found in ${WORDLISTS_DIR}/${NC}"
        echo -e "${YELLOW}    Consider copying from /usr/share/wordlists/${NC}"
    fi
}
create_directories

# ============================================================================
# TOOL PATHS (SYSTEM INSTALLED)
# ============================================================================

# Default system tool paths (customize these for your system)
declare -A TOOL_PATHS=(
    # Go tools
    ["assetfinder"]="$HOME/go/bin/assetfinder"
    ["subfinder"]="$HOME/go/bin/subfinder"
    ["httprobe"]="$HOME/go/bin/httprobe"
    ["waybackurls"]="$HOME/go/bin/waybackurls"
    ["gau"]="$HOME/go/bin/gau"
    ["unfurl"]="$HOME/go/bin/unfurl"
    ["chaos"]="$HOME/go/bin/chaos"
    ["haktrails"]="$HOME/go/bin/haktrails"
    
    # System tools
    ["gobuster"]="/usr/bin/gobuster"
    ["python3"]="/usr/bin/python3"
    ["curl"]="/usr/bin/curl"
    ["nmap"]="/usr/bin/nmap"
    ["dig"]="/usr/bin/dig"
    ["whois"]="/usr/bin/whois"
    
    # Custom tools
    ["findomain"]="$HOME/tools/findomain"
    ["sublist3r"]="$HOME/tools/Sublist3r/sublist3r.py"
    ["theHarvester"]="$HOME/tools/theHarvester/theHarvester.py"
    ["bbot"]="$HOME/.local/bin/bbot"
    ["ffuf"]="$HOME/go/bin/ffuf"
)

# Load custom tool paths if config exists
if [ -f "${CONFIG_DIR}/tool_paths.conf" ]; then
    echo -e "${GREEN}[+] Loading custom tool paths...${NC}"
    source "${CONFIG_DIR}/tool_paths.conf"
fi

# Function to validate tool
validate_tool() {
    local tool_name="$1"
    local tool_path="${TOOL_PATHS[$tool_name]}"
    
    if [ -z "$tool_path" ]; then
        # Check if tool is in PATH
        if command -v "$tool_name" &> /dev/null; then
            TOOL_PATHS["$tool_name"]="$(command -v "$tool_name")"
            return 0
        fi
        return 1
    fi
    
    if [ -x "$tool_path" ] || [[ "$tool_path" == *.py && -f "$tool_path" ]]; then
        return 0
    fi
    
    return 1
}

# Test critical tools
echo -e "${BLUE}[+] Validating tools...${NC}"
CRITICAL_TOOLS=("python3" "curl" "assetfinder" "subfinder")
MISSING_TOOLS=()

for tool in "${CRITICAL_TOOLS[@]}"; do
    if validate_tool "$tool"; then
        echo -e "  ${GREEN}✓${NC} $tool: ${TOOL_PATHS[$tool]}"
    else
        echo -e "  ${RED}✗${NC} $tool: NOT FOUND"
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo -e "${RED}[!] Missing critical tools: ${MISSING_TOOLS[*]}${NC}"
    echo -e "${YELLOW}    Update ${CONFIG_DIR}/tool_paths.conf with correct paths${NC}"
    exit 1
fi

# ============================================================================
# CONFIGURATION LOADING
# ============================================================================

# Default configuration
RATE_LIMIT_DELAY=1
BATCH_DELAY=3
MAX_THREADS=10
ENABLE_RATE_LIMIT=true

# API Keys (loaded from secure file)
GITHUB_TOKEN=""
VIRUSTOTAL_API_KEY=""
CHAOS_API_KEY=""
SHODAN_API_KEY=""

# Load configuration
load_config() {
    # Load main config
    if [ -f "${CONFIG_DIR}/recon.conf" ]; then
        source "${CONFIG_DIR}/recon.conf"
    else
        create_default_config
    fi
    
    # Load API keys from secure file
    if [ -f "${CONFIG_DIR}/.api_keys" ]; then
        echo -e "${GREEN}[+] Loading API keys...${NC}"
        source "${CONFIG_DIR}/.api_keys"
    else
        echo -e "${YELLOW}[!] No API keys file found${NC}"
        echo -e "${YELLOW}    Create ${CONFIG_DIR}/.api_keys with your tokens${NC}"
    fi
}

# Create default config
create_default_config() {
    cat > "${CONFIG_DIR}/recon.conf" << 'EOF'
# Recon Script Configuration
# ==========================

# Rate Limiting
RATE_LIMIT_DELAY=1        # Seconds between requests
BATCH_DELAY=3            # Seconds between tool batches
MAX_THREADS=10           # Maximum threads for parallel tools
ENABLE_RATE_LIMIT=true   # Enable/disable rate limiting

# Scanning Options
ENABLE_SUBDOMAIN_ENUM=true
ENABLE_CONTENT_DISCOVERY=true
ENABLE_VULN_SCANNING=false
ENABLE_GITHUB_DORKING=true

# Wordlists
COMMON_WORDLIST="wordlists/common.txt"
DIRB_WORDLIST="wordlists/dirb/common.txt"
SUBDOMAIN_WORDLIST="wordlists/subdomains.txt"

# Output
KEEP_RAW_OUTPUT=true
COMPRESS_RESULTS=true
EOF
    echo -e "${GREEN}[+] Created default config: ${CONFIG_DIR}/recon.conf${NC}"
}

# Rate limiting function
rate_limit() {
    if [ "$ENABLE_RATE_LIMIT" != "true" ]; then
        return
    fi
    
    local delay=$RATE_LIMIT_DELAY
    # Add randomness to avoid detection
    if [ $delay -gt 0 ]; then
        delay=$((delay + RANDOM % 2))
        sleep $delay
    fi
}

# ============================================================================
# TARGET INPUT
# ============================================================================

echo -e "${CYAN}"
echo "========================================"
echo "        TARGET CONFIGURATION"
echo "========================================"
echo -e "${NC}"

# Check for existing target files
TARGET_FILES=("${TARGETS_DIR}/domains.txt" "${TARGETS_DIR}/githubRepo.txt" "${TARGETS_DIR}/cidr.txt")
MISSING_FILES=()

for file in "${TARGET_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$(basename "$file")")
    fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo -e "${YELLOW}[!] Missing target files: ${MISSING_FILES[*]}${NC}"
    echo -e "${YELLOW}    Please create them in ${TARGETS_DIR}/${NC}"
    
    # Create sample files if missing
    if [ ! -f "${TARGETS_DIR}/domains.txt" ]; then
        echo -e "${BLUE}[+] Creating sample domains.txt...${NC}"
        echo "# Add target domains here (one per line)" > "${TARGETS_DIR}/domains.txt"
        echo "# example.com" >> "${TARGETS_DIR}/domains.txt"
        echo "# target.org" >> "${TARGETS_DIR}/domains.txt"
    fi
fi

# Get target from user
read -p "Enter target domain: " TARGET
if [ -z "$TARGET" ]; then
    echo -e "${RED}[!] No target specified${NC}"
    exit 1
fi

# Create timestamp for this scan
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SCAN_DIR="${OUTPUT_BASE}/${TARGET}_${TIMESTAMP}"

echo -e "${GREEN}[+] Scan directory: ${SCAN_DIR}${NC}"

# ============================================================================
# CREATE SCAN DIRECTORY STRUCTURE
# ============================================================================

create_scan_directories() {
    echo -e "${BLUE}[+] Creating scan directories...${NC}"
    
    # Main directories
    mkdir -p "${SCAN_DIR}/asset-discovery"
    mkdir -p "${SCAN_DIR}/content-discovery"
    mkdir -p "${SCAN_DIR}/fingerprinting"
    mkdir -p "${SCAN_DIR}/exploitation"
    mkdir -p "${SCAN_DIR}/handson"
    mkdir -p "${SCAN_DIR}/reports"
    
    # Subdirectories
    mkdir -p "${SCAN_DIR}/exploitation/403-bypass"
    mkdir -p "${SCAN_DIR}/exploitation/api"
    mkdir -p "${SCAN_DIR}/exploitation/cors"
    mkdir -p "${SCAN_DIR}/exploitation/idor"
    mkdir -p "${SCAN_DIR}/exploitation/redirects"
    mkdir -p "${SCAN_DIR}/reports/smtp"
    mkdir -p "${SCAN_DIR}/reports/iis-shortnames"
    
    # Create README
    cat > "${SCAN_DIR}/README.md" << EOF
# Recon Scan: $TARGET
- Date: $(date)
- Timestamp: $TIMESTAMP
- Script: $SCRIPT_NAME
- USB Location: $USB_BASE

## Directory Structure
- asset-discovery/ - Subdomains, IPs, assets
- content-discovery/ - URLs, endpoints, files
- fingerprinting/ - Technologies, services
- exploitation/ - Vulnerability testing
- handson/ - Manual testing notes
- reports/ - Findings and reports

## Notes
$(date)
EOF
}
create_scan_directories

# ============================================================================
# MAIN RECON FUNCTIONS
# ============================================================================

# Function to run tool with error handling
run_tool() {
    local tool_name="$1"
    local command="$2"
    local description="$3"
    local output_file="$4"
    
    echo -e "${CYAN}[+] ${description}...${NC}"
    
    if ! validate_tool "$tool_name"; then
        echo -e "${YELLOW}[!] Skipping ${tool_name} (not found)${NC}"
        return 1
    fi
    
    # Create output directory if needed
    if [ -n "$output_file" ]; then
        mkdir -p "$(dirname "$output_file")"
    fi
    
    # Execute command
    set +e  # Don't exit on error for individual tools
    if [ -n "$output_file" ]; then
        eval "$command" >> "$output_file" 2>&1
        local exit_code=$?
    else
        eval "$command"
        local exit_code=$?
    fi
    set -e
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}[✓] ${description} completed${NC}"
    else
        echo -e "${YELLOW}[!] ${description} had issues (exit code: $exit_code)${NC}"
    fi
    
    rate_limit
    return $exit_code
}

# ============================================================================
# ASSET DISCOVERY - SUBDOMAIN ENUMERATION
# ============================================================================

echo -e "${CYAN}"
echo "========================================"
echo "        ASSET DISCOVERY PHASE"
echo "========================================"
echo -e "${NC}"

# 1. Assetfinder
run_tool "assetfinder" "${TOOL_PATHS[assetfinder]} $TARGET | grep -i $TARGET | sort -u" \
    "Assetfinder subdomain enumeration" \
    "${SCAN_DIR}/asset-discovery/assetfinder.txt"

# 2. Subfinder
run_tool "subfinder" "${TOOL_PATHS[subfinder]} -d $TARGET -silent" \
    "Subfinder subdomain enumeration" \
    "${SCAN_DIR}/asset-discovery/subfinder.txt"

# 3. Findomain (if available)
if validate_tool "findomain"; then
    run_tool "findomain" "${TOOL_PATHS[findomain]} -t $TARGET --quiet" \
        "Findomain subdomain enumeration" \
        "${SCAN_DIR}/asset-discovery/findomain.txt"
fi

# 4. Amass (optional - not in original but useful)
if command -v amass &> /dev/null; then
    run_tool "amass" "amass enum -passive -d $TARGET" \
        "Amass passive enumeration" \
        "${SCAN_DIR}/asset-discovery/amass.txt"
fi

# Combine all subdomains
combine_subdomains() {
    echo -e "${BLUE}[+] Combining subdomain results...${NC}"
    
    cat "${SCAN_DIR}"/asset-discovery/*.txt 2>/dev/null | \
        grep -i "$TARGET" | \
        sed 's/^\*\.//' | \
        sort -u > "${SCAN_DIR}/asset-discovery/all_subdomains_raw.txt"
    
    # Count results
    COUNT=$(wc -l < "${SCAN_DIR}/asset-discovery/all_subdomains_raw.txt" 2>/dev/null || echo 0)
    echo -e "${GREEN}[+] Found ${COUNT} subdomains${NC}"
}
combine_subdomains

# ============================================================================
# LIVE HOST DISCOVERY
# ============================================================================

echo -e "${CYAN}"
echo "========================================"
echo "        LIVE HOST DISCOVERY"
echo "========================================"
echo -e "${NC}"

# Check which subdomains are live
if validate_tool "httprobe" && [ -f "${SCAN_DIR}/asset-discovery/all_subdomains_raw.txt" ]; then
    echo -e "${BLUE}[+] Probing for live hosts...${NC}"
    
    # Use httprobe with rate limiting
    cat "${SCAN_DIR}/asset-discovery/all_subdomains_raw.txt" | \
        ${TOOL_PATHS[httprobe]} -c 50 -t 3000 | \
        sort -u > "${SCAN_DIR}/asset-discovery/live_hosts.txt"
    
    LIVE_COUNT=$(wc -l < "${SCAN_DIR}/asset-discovery/live_hosts.txt" 2>/dev/null || echo 0)
    echo -e "${GREEN}[+] Found ${LIVE_COUNT} live hosts${NC}"
    
    # Create HTTP and HTTPS lists
    grep "^http://" "${SCAN_DIR}/asset-discovery/live_hosts.txt" > "${SCAN_DIR}/asset-discovery/http_hosts.txt"
    grep "^https://" "${SCAN_DIR}/asset-discovery/live_hosts.txt" > "${SCAN_DIR}/asset-discovery/https_hosts.txt"
    
    # Create domain-only list (for other tools)
    sed 's|^https\?://||' "${SCAN_DIR}/asset-discovery/live_hosts.txt" | \
        sed 's|:.*$||' | \
        sort -u > "${SCAN_DIR}/asset-discovery/live_domains.txt"
fi

# ============================================================================
# CONTENT DISCOVERY
# ============================================================================

echo -e "${CYAN}"
echo "========================================"
echo "        CONTENT DISCOVERY"
echo "========================================"
echo -e "${NC}"

# Wayback URLs
if validate_tool "waybackurls" && [ -f "${SCAN_DIR}/asset-discovery/live_domains.txt" ]; then
    echo -e "${BLUE}[+] Gathering URLs from Wayback Machine...${NC}"
    
    while read -r domain; do
        run_tool "waybackurls" "echo $domain | ${TOOL_PATHS[waybackurls]}" \
            "Wayback URLs for $domain" \
            "${SCAN_DIR}/content-discovery/wayback_urls.txt"
    done < "${SCAN_DIR}/asset-discovery/live_domains.txt"
fi

# GAU (GitHub, AlienVault, CommonCrawl)
if validate_tool "gau" && [ -f "${SCAN_DIR}/asset-discovery/live_domains.txt" ]; then
    echo -e "${BLUE}[+] Gathering URLs with GAU...${NC}"
    
    while read -r domain; do
        run_tool "gau" "${TOOL_PATHS[gau]} $domain" \
            "GAU for $domain" \
            "${SCAN_DIR}/content-discovery/gau_urls.txt"
        sleep 1  # Rate limit for GAU
    done < "${SCAN_DIR}/asset-discovery/live_domains.txt"
fi

# Combine and unique URLs
if [ -f "${SCAN_DIR}/content-discovery/wayback_urls.txt" ] || [ -f "${SCAN_DIR}/content-discovery/gau_urls.txt" ]; then
    echo -e "${BLUE}[+] Processing discovered URLs...${NC}"
    
    cat "${SCAN_DIR}"/content-discovery/*.txt 2>/dev/null | \
        sort -u > "${SCAN_DIR}/content-discovery/all_urls.txt"
    
    URL_COUNT=$(wc -l < "${SCAN_DIR}/content-discovery/all_urls.txt" 2>/dev/null || echo 0)
    echo -e "${GREEN}[+] Found ${URL_COUNT} unique URLs${NC}"
    
    # Extract interesting patterns
    grep -E "(api|admin|dashboard|login|signin|auth|token|key|secret|config|backup|debug|test)" \
        "${SCAN_DIR}/content-discovery/all_urls.txt" | \
        sort -u > "${SCAN_DIR}/content-discovery/interesting_urls.txt"
fi

# ============================================================================
# DIRECTORY BRUTE FORCING
# ============================================================================

echo -e "${CYAN}"
echo "========================================"
echo "        DIRECTORY BRUTE FORCING"
echo "========================================"
echo -e "${NC}"

# Gobuster directory scanning
if validate_tool "gobuster" && [ -f "${SCAN_DIR}/asset-discovery/live_hosts.txt" ]; then
    echo -e "${BLUE}[+] Directory brute forcing (first 5 hosts)...${NC}"
    
    # Use first 5 live hosts
    head -5 "${SCAN_DIR}/asset-discovery/live_hosts.txt" | while read -r url; do
        # Clean URL for directory name
        DIR_NAME=$(echo "$url" | sed 's|https\?://||' | sed 's|/.*$||' | tr '.' '_')
        
        run_tool "gobuster" "${TOOL_PATHS[gobuster]} dir -u \"$url\" -w ${WORDLISTS_DIR}/common.txt -t 20 --wildcard --exclude-length 0" \
            "Gobuster on $url" \
            "${SCAN_DIR}/content-discovery/gobuster_${DIR_NAME}.txt"
    done
fi

# ============================================================================
# FINGERPRINTING
# ============================================================================

echo -e "${CYAN}"
echo "========================================"
echo "        TECHNOLOGY FINGERPRINTING"
echo "========================================"
echo -e "${NC}"

# WhatWeb for technology detection
if command -v whatweb &> /dev/null && [ -f "${SCAN_DIR}/asset-discovery/live_hosts.txt" ]; then
    echo -e "${BLUE}[+] Technology fingerprinting...${NC}"
    
    # Sample first 10 hosts
    head -10 "${SCAN_DIR}/asset-discovery/live_hosts.txt" | while read -r url; do
        run_tool "whatweb" "whatweb -a 3 \"$url\"" \
            "WhatWeb for $url" \
            "${SCAN_DIR}/fingerprinting/whatweb.txt"
    done
fi

# ============================================================================
# GITHUB RECON (if token available)
# ============================================================================

if [ -n "$GITHUB_TOKEN" ]; then
    echo -e "${CYAN}"
    echo "========================================"
    echo "        GITHUB RECONNAISSANCE"
    echo "========================================"
    echo -e "${NC}"
    
    echo -e "${BLUE}[+] Searching GitHub for $TARGET...${NC}"
    
    # Search for repos
    run_tool "curl" "curl -s -H \"Authorization: token $GITHUB_TOKEN\" \"https://api.github.com/search/repositories?q=$TARGET&sort=updated&order=desc\"" \
        "GitHub repository search" \
        "${SCAN_DIR}/reports/github_repos.json"
    
    # Search for code
    run_tool "curl" "curl -s -H \"Authorization: token $GITHUB_TOKEN\" \"https://api.github.com/search/code?q=$TARGET+in:file&sort=updated&order=desc\"" \
        "GitHub code search" \
        "${SCAN_DIR}/reports/github_code.json"
    
    # Be respectful of GitHub rate limits
    sleep 10
fi

# ============================================================================
# PORT SCANNING (lightweight)
# ============================================================================

echo -e "${CYAN}"
echo "========================================"
echo "        PORT SCANNING"
echo "========================================"
echo -e "${NC}"

if validate_tool "nmap" && [ -f "${SCAN_DIR}/asset-discovery/live_domains.txt" ]; then
    echo -e "${BLUE}[+] Quick port scan (top ports)...${NC}"
    
    # Scan first 3 domains
    head -3 "${SCAN_DIR}/asset-discovery/live_domains.txt" | while read -r domain; do
        run_tool "nmap" "${TOOL_PATHS[nmap]} -sS -T4 --top-ports 100 $domain" \
            "Nmap scan for $domain" \
            "${SCAN_DIR}/fingerprinting/nmap_${domain}.txt"
    done
fi

# ============================================================================
# REPORT GENERATION
# ============================================================================

echo -e "${CYAN}"
echo "========================================"
echo "        GENERATING REPORTS"
echo "========================================"
echo -e "${NC}"

generate_report() {
    echo -e "${BLUE}[+] Generating final report...${NC}"
    
    cat > "${SCAN_DIR}/reports/summary.md" << EOF
# Reconnaissance Summary
## Target: $TARGET
## Date: $(date)
## Duration: $((SECONDS / 60)) minutes

## Assets Discovered
### Subdomains
- Total subdomains found: $(wc -l < "${SCAN_DIR}/asset-discovery/all_subdomains_raw.txt" 2>/dev/null || echo 0)
- Live hosts: $(wc -l < "${SCAN_DIR}/asset-discovery/live_hosts.txt" 2>/dev/null || echo 0)

### URLs
- Total URLs discovered: $(wc -l < "${SCAN_DIR}/content-discovery/all_urls.txt" 2>/dev/null || echo 0)
- Interesting URLs: $(wc -l < "${SCAN_DIR}/content-discovery/interesting_urls.txt" 2>/dev/null || echo 0)

## Tools Used
$(for tool in "${!TOOL_PATHS[@]}"; do
    if validate_tool "$tool"; then
        echo "- $tool"
    fi
done)

## Files Generated
$(find "${SCAN_DIR}" -type f -name "*.txt" -o -name "*.json" -o -name "*.md" | sed 's|.*/||' | sort | while read -r file; do
    echo "- $file"
done)

## Next Steps
1. Review interesting URLs: ${SCAN_DIR}/content-discovery/interesting_urls.txt
2. Check for vulnerabilities in live hosts
3. Manual testing with: ${SCAN_DIR}/handson/

## Notes
Scan completed at $(date)
EOF
    
    echo -e "${GREEN}[+] Report saved: ${SCAN_DIR}/reports/summary.md${NC}"
}
generate_report

# ============================================================================
# CLEANUP AND FINALIZATION
# ============================================================================

echo -e "${CYAN}"
echo "========================================"
echo "        SCAN COMPLETE"
echo "========================================"
echo -e "${NC}"

# Compress results if requested
if [ "$COMPRESS_RESULTS" = "true" ]; then
    echo -e "${BLUE}[+] Compressing results...${NC}"
    tar -czf "${SCAN_DIR}.tar.gz" -C "$(dirname "$SCAN_DIR")" "$(basename "$SCAN_DIR")"
    echo -e "${GREEN}[+] Archive created: ${SCAN_DIR}.tar.gz${NC}"
fi

# Summary
echo -e "${GREEN}"
echo "========================================"
echo "SUMMARY"
echo "========================================"
echo -e "${NC}"
echo "Target:           $TARGET"
echo "Scan directory:   $SCAN_DIR"
echo "Subdomains:       $(wc -l < "${SCAN_DIR}/asset-discovery/all_subdomains_raw.txt" 2>/dev/null || echo 0)"
echo "Live hosts:       $(wc -l < "${SCAN_DIR}/asset-discovery/live_hosts.txt" 2>/dev/null || echo 0)"
echo "URLs discovered:  $(wc -l < "${SCAN_DIR}/content-discovery/all_urls.txt" 2>/dev/null || echo 0)"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Review ${SCAN_DIR}/reports/summary.md"
echo "2. Check ${SCAN_DIR}/content-discovery/interesting_urls.txt"
echo "3. Begin manual testing in ${SCAN_DIR}/handson/"
echo ""
echo -e "${YELLOW}Remember: Always test ethically with proper authorization!${NC}"

# Save scan info
echo "$(date),$TARGET,$SCAN_DIR" >> "${USB_BASE}/scan_history.csv"

exit 0
