#!/bin/bash

echo "🧰 Starting DevOps Lab Tools Installation..."

# Update and install core utilities
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git unzip apt-transport-https gnupg lsb-release software-properties-common

echo "🔧 Installing VirtualBox 7.1 (you already have it, so we skip unless reinstall is needed)..."

# Check if VirtualBox already installed
if ! command -v vboxmanage &> /dev/null; then
  echo "Installing VirtualBox 7.1.8..."
  wget https://download.virtualbox.org/virtualbox/7.1.8/virtualbox-7.1_7.1.8-168469~Ubuntu~focal_amd64.deb
  sudo dpkg -i virtualbox-7.1_7.1.8-168469~Ubuntu~focal_amd64.deb
  sudo apt install -f -y
else
  echo "✅ VirtualBox already installed."
fi

echo "📦 Installing Vagrant 2.4.5..."
wget https://releases.hashicorp.com/vagrant/2.4.5/vagrant_2.4.5_amd64.deb
sudo dpkg -i vagrant_2.4.5_amd64.deb
sudo apt install -f -y

echo "🔌 Installing Vagrant plugins..."
vagrant plugin expunge --force --reinstall
vagrant plugin install vagrant-vbguest

echo "🧬 Installing Java JDK 8..."
sudo apt install -y openjdk-8-jdk

echo "📦 Installing Apache Maven..."
sudo apt install -y maven

echo "💻 (Optional) Installing IntelliJ IDEA (Community Edition via Snap)..."
sudo snap install intellij-idea-community --classic

echo "📝 (Optional) Installing Sublime Text..."
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo add-apt-repository "deb https://download.sublimetext.com/ apt/stable/"
sudo apt update
sudo apt install -y sublime-text

echo "🌐 Installing Alibaba Cloud CLI (aliyun-cli)..."
wget https://aliyuncli.alicdn.com/aliyun-cli-linux-3.0.189-amd64.tgz
tar -xvzf aliyun-cli-linux-3.0.189-amd64.tgz
sudo mv aliyun /usr/local/bin/
rm aliyun-cli-linux-3.0.189-amd64.tgz

echo "✅ DevOps Lab Tools Installation Complete!"

