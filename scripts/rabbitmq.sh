#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y mc curl gnupg apt-transport-https

curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc | sudo apt-key add -
sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list <<EOF
deb https://dl.bintray.com/rabbitmq-erlang/debian focal erlang
deb https://dl.bintray.com/rabbitmq/debian focal main
EOF
sudo apt-get update -y

sudo apt-get install -y erlang rabbitmq-server

sudo systemctl stop rabbitmq-server

sudo tee /etc/rabbitmq/rabbitmq.conf <<EOF
loopback_users = none
EOF

sudo rabbitmq-plugins enable rabbitmq_management

sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server

sleep 10
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test admin
sudo rabbitmqctl set_permissions -p / test ".*" ".*" ".*"

sudo ufw allow 5672/tcp    
sudo ufw allow 15672/tcp   
sudo ufw reload

sudo systemctl status rabbitmq-server


# sudo apt install docker.io
# sudo docker pull rabbitmq:management
# sudo docker run -d \
#   --name rabbitmq \
#   -p 5672:5672 \  # AMQP (основной протокол)
#   -p 15672:15672 \  # Веб-интерфейс (если включен)
#   -e RABBITMQ_DEFAULT_USER=admin \  # Опционально: логин
#   -e RABBITMQ_DEFAULT_PASS=secret \  # Опционально: пароль
#   rabbitmq:management  # Образ с веб-интерфейсом