#!/bin/bash
# One-click config for Tailscale setup and install on Ubuntu 22.04 LTS servers!
# (C) Kinbe Gakukuru 2023.  Licensed under BSD-2.
printf "Warning: Admin password is required for this installation!\nThis is your user password by default.\nNothing malicious is being downloaded. Stay calm!"

# Update system and install packages.
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install \
	curl \
	unattended-upgrades \
       	openssh-server \
	ssh-import-id -y

# Original steps taken from offical Tailscale documentation: https://tailscale.com/kb/1187/install-ubuntu-2204/
# Add Tailscale keys and repos to apt.
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt-get update
sudo apt-get install tailscale 

# Configure SSH server.
sudo systemctl enable ssh.service
ssh-import-id-gh C0deEve
ssh-import-id-gh KinbeGakukuru
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bkp
sudo sed -i /etc/ssh/sshd_config 's/#PasswordAuthentication yes/PasswordAuthentication no/g'
sudo systemctl restart ssh.service

# Configure device as exit node
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
sudo tailscale up --advertise-exit-node
