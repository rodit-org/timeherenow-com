#!/bin/bash
# SSL Certificate Setup for discernible.io using Let's Encrypt
# This script installs Certbot and obtains SSL certificates

set -e

DOMAIN="discernible.io"
EMAIL="webmaster@discernible.io"

echo "=== SSL Certificate Setup for $DOMAIN ==="
echo ""

# Check if Certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Certbot is not installed. Installing Certbot..."
    sudo apt update
    sudo apt install -y certbot python3-certbot-apache
    echo "✓ Certbot installed successfully"
else
    echo "✓ Certbot is already installed"
fi

# Prompt for email if default is used
read -p "Enter your email address for certificate notifications [$EMAIL]: " user_email
EMAIL=${user_email:-$EMAIL}

echo ""
echo "Obtaining SSL certificates for:"
echo "  - $DOMAIN"
echo "  - www.$DOMAIN"
echo ""
echo "Email for notifications: $EMAIL"
echo ""

# Obtain certificates
echo "Running Certbot..."
sudo certbot --apache \
    --non-interactive \
    --agree-tos \
    --email "$EMAIL" \
    --domains "$DOMAIN,www.$DOMAIN" \
    --redirect

echo ""
echo "✓ SSL certificates obtained successfully!"
echo ""
echo "Certificate details:"
sudo certbot certificates

echo ""
echo "Your website is now accessible via HTTPS:"
echo "  - https://$DOMAIN"
echo "  - https://www.$DOMAIN"
echo ""
echo "Certificates will auto-renew. Test renewal with:"
echo "  sudo certbot renew --dry-run"
