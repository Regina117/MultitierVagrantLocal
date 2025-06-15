#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install -y mc redis-server redis-tools

sudo sed -i 's/bind 127.0.0.1 ::1/bind 0.0.0.0/' /etc/redis/redis.conf
sudo sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf

sudo systemctl restart redis-server
sudo systemctl enable redis-server


sudo ufw allow 6379/tcp
sudo ufw reload
sudo systemctl status redis-server

redis-cli ping

