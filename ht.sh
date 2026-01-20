#!/bin/bash

# Update system
sudo yum update -y

# Install Apache (httpd)
sudo yum install httpd -y

# Start Apache service
sudo systemctl start httpd

# Enable Apache on boot
sudo systemctl enable httpd

# Allow HTTP through firewall (if firewalld exists)
if systemctl is-active --quiet firewalld; then
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --reload
fi

# Check status

echo "Apache HTTP Server installed successfully!"
echo "Access it via: http://$(hostname -I | awk '{print $1}')"

