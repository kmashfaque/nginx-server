# Virtual Environment Setup

This project uses Node.js. Here's how to set up a virtual environment:

## Option 1: Using nvm (Recommended)

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Restart shell or source
source ~/.bashrc

# Install Node.js version
nvm install 18
nvm use 18

# Verify
node --version
npm --version
```

## Option 2: Using n (Node version manager)

```bash
# Install n globally
npm install -g n

# Install Node.js version
n 18

# Switch to the version
n 18
```

## Option 3: Using Docker

```bash
# Build image
docker build -t nginx-webserver .

# Run container
docker run -p 3000:3000 -p 80:80 -p 443:443 nginx-webserver
```

## Running the Application

```bash
# Install dependencies
npm install

# Start backend server
npm start
```

The server will start on port 3000.