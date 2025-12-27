#!/bin/bash

set -e

echo "[+] Updating package lists..."
sudo apt update

echo "[+] Performing distribution upgrade..."
sudo apt dist-upgrade -y

echo "[+] Removing unused packages..."
sudo apt autoremove -y

echo "[✔] Kali system update completed successfully."
