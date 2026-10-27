#!/bin/bash
set -e

echo "=== 1. Setting up 2GB Swap Space ==="
if [ ! -f /swapfile ]; then
    sudo fallocate -l 2G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

echo "=== 2. Updating Packages & Installing Prerequisites ==="
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release git htop ufw net-tools

echo "=== 3. Installing Official Docker Engine & Compose ==="
sudo install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
fi

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu

echo "=== 4. Setting up Project Directories ==="
mkdir -p /home/ubuntu/pr-tracker/nagios/conf.d
sudo chown -R ubuntu:ubuntu /home/ubuntu/pr-tracker

echo "=== 5. Verifying Installation ==="
docker --version
docker compose version
free -m
echo "=== Bootstrap Completed Successfully ==="
