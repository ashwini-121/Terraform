#!/bin/bash
sudo -i
yum update -y
yum install httpd -y
echo "UnHealthy" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
cd /var/www/html
touch test.html