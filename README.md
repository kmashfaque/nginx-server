# Nginx Secure Web Server

A production-like secure web server using Nginx with HTTPS, SSL, and Reverse Proxy.

## Overview

This project sets up a secure Nginx web server with:
- Static website hosting
- HTTPS using self-signed SSL certificate
- HTTP → HTTPS automatic redirect
- Reverse proxy to Node.js backend on port 3000

## Project Structure

```
nginx-webserver/
├── public/
│   └── index.html          # Frontend HTML page
├── configs/
│   └── nginx.conf         # Nginx configuration
├── server.js              # Node.js backend server
├── package.json          # Node.js dependencies
├── setup.sh              # Automated setup script
└── README.md            # Documentation
```

## Part 1: Basic Setup

### Install Nginx & OpenSSL

```bash
sudo apt update
sudo apt install -y nginx openssl
```

### Create Web Root Directory

```bash
sudo mkdir -p /var/www/secure-app
sudo chmod -R 755 /var/www/secure-app
```

### Create HTML Page

Copy `public/index.html` to `/var/www/secure-app/`:

```bash
sudo cp public/index.html /var/www/secure-app/
```

## Part 2: SSL Certificate

### Generate Self-Signed SSL (365 days)

```bash
sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
```

Certificate stored in:
- Certificate: `/etc/nginx/ssl/server.crt`
- Private Key: `/etc/nginx/ssl/server.key`

## Part 3: Nginx Configuration

### Custom Configuration

Create `/etc/nginx/sites-available/secure-app`:

```nginx
server {
    listen 80;
    server_name _;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name _;

    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;

    root /var/www/secure-app;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Enable Configuration

```bash
sudo ln -sf /etc/nginx/sites-available/secure-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
```

## Part 4: Reverse Proxy

### Backend Server (Port 3000)

Start the Node.js backend:

```bash
cd nginx-webserver
npm install
node server.js
```

Backend runs on `http://localhost:3000`

### Nginx Proxy Configuration

The reverse proxy is configured in Part 3 (see `configs/nginx.conf`).

Key proxy settings:
- `proxy_pass http://localhost:3000`
- `proxy_set_header Host $host`
- `proxy_set_header X-Real-IP $remote_addr`
- `proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for`

## Part 5: Testing

### Test Nginx Configuration

```bash
sudo nginx -t
```

Expected output:
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Reload Nginx

```bash
sudo systemctl reload nginx
```

### Test HTTP → HTTPS Redirect

```bash
curl -I http://localhost
```

Expected: `301 Moved Permanently` redirecting to HTTPS

### Test HTTPS Working

```bash
curl -I https://localhost
```

Expected: `200 OK` response

### Test Backend via Nginx

```bash
curl https://localhost/api/health
```

Expected: JSON response from backend

```json
{"status":"healthy","message":"Backend server is running","timestamp":"..."}
```

## Running the Application

### Quick Start (Automated)

```bash
chmod +x setup.sh
./setup.sh
```

### Manual Start

1. Install dependencies:
```bash
npm install
```

2. Start backend server:
```bash
node server.js
```

3. In another terminal, start Nginx (or use the automated setup)

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| `/` | Static website |
| `/api/health` | Health check |
| `/api/info` | Server information |
| `/api/data` | Sample data |

## Virtual Environment

To create a virtual environment for Node.js:

```bash
# Using nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18

# Or using node version manager
nvm install 18
nvm use 18
```

## Screenshots

After setup, you should see:

1. **HTTP Redirect**: `curl -I http://localhost` returns 301
2. **HTTPS Working**: `curl -I https://localhost` returns 200
3. **Backend Running**: `curl https://localhost/api/health` returns JSON

## License

MIT