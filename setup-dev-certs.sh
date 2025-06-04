#!/bin/bash

echo "🔧 Setting up development HTTPS certificates..."

# Check if mkcert is installed
if ! command -v mkcert &>/dev/null; then
  echo "❌ mkcert not found. Installing..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install mkcert nss
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Please install mkcert manually: https://github.com/FiloSottile/mkcert#installation"
    exit 1
  else
    echo "Please install mkcert manually: https://github.com/FiloSottile/mkcert#installation"
    exit 1
  fi
fi

# Install CA
echo "🔐 Installing CA certificate..."
mkcert -install

# Create certs directory
mkdir -p ./traefik/certs

# Generate certificates
echo "📜 Generating *.localhost certificates..."
mkcert -cert-file ./traefik/certs/localhost-cert.pem -key-file ./traefik/certs/localhost-key.pem localhost traefik.localhost playwright.localhost rebrowser.localhost "*.localhost"

echo "🔄 Restarting containers to load certificates..."
docker compose restart traefik

echo "✅ Development HTTPS setup complete!"
echo "🌐 Visit: https://traefik.localhost:8080"
