#!/bin/bash

echo "=== Nginx Secure Server Setup ==="
echo ""

echo "Step 1: Installing Nginx and OpenSSL..."
sudo apt update
sudo apt install -y nginx openssl

echo ""
echo "Step 2: Creating web root directory..."
sudo mkdir -p /var/www/secure-app
sudo chmod -R 755 /var/www/secure-app
sudo chown -R $USER:$USER /var/www/secure-app

echo ""
echo "Step 3: Copying HTML files..."
cp -r public/* /var/www/secure-app/
echo "HTML files copied to /var/www/secure-app/"

echo ""
echo "Step 4: Creating SSL directory..."
sudo mkdir -p /etc/nginx/ssl

echo ""
echo "Step 5: Generating self-signed SSL certificate..."
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

echo "SSL certificate generated in /etc/nginx/ssl/"

echo ""
echo "Step 6: Configuring Nginx..."
sudo cp configs/nginx.conf /etc/nginx/sites-available/secure-app
sudo ln -sf /etc/nginx/sites-available/secure-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

echo ""
echo "Step 7: Testing Nginx configuration..."
sudo nginx -t

echo ""
echo "Step 8: Starting backend server..."
cd /home/$USER/nginx-webserver
node server.js &
echo "Backend server started on port 3000"

echo ""
echo "Step 9: Reloading Nginx..."
sudo systemctl reload nginx

echo ""
echo "=== Setup Complete ==="
echo ""
echo "HTTP redirect: http://localhost -> https://localhost"
echo "HTTPS server: https://localhost"
echo "Backend API: https://localhost/api/health"
echo ""
echo "To test manually:"
echo "  curl -I http://localhost"
echo "  curl -I https://localhost"
echo "  curl https://localhost/api/health"