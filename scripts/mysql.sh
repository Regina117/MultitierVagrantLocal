#!/bin/bash
sudo apt update
sudo apt install -y mysql-server
sudo systemctl enable mysql
sudo systemctl start mysql

sudo mysql <<EOF
CREATE DATABASE multidb;
CREATE USER 'multi'@'%' IDENTIFIED BY 'multidev';
GRANT ALL PRIVILEGES ON multidb.* TO 'multi'@'%';
FLUSH PRIVILEGES;
EOF

sudo sed -i "s/^bind-address\s*=.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

sudo systemctl restart mysql