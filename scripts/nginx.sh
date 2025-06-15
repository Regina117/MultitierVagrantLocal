#!/bin/bash
sudo apt update
sudo apt install mc
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

echo "192.168.56.11 backend" | sudo tee -a /etc/hosts > /dev/null

sudo bash -c 'cat > /etc/nginx/sites-available/vproxyapp <<EOF
upstream backend {
    server backend:8080;  
}

server {
    listen 80;

    location / {
        proxy_pass http://backend;  
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF'

sudo nginx -t

sudo systemctl reload nginx

sudo rm -rf /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/vproxyapp /etc/nginx/sites-enabled/vproxyapp
