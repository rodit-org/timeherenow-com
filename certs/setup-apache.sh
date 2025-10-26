#!/bin/bash
# Apache Configuration Setup for discernible.io
# This script configures Apache for the domain

set -e

DOMAIN="discernible.io"
VHOST_FILE="/etc/apache2/sites-available/$DOMAIN.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Setting up Apache configuration for $DOMAIN ==="

# Check if Apache is installed
if ! command -v apache2 &> /dev/null; then
    echo "Apache is not installed. Installing Apache2..."
    sudo apt update
    sudo apt install -y apache2
else
    echo "✓ Apache2 is already installed"
fi

# Copy virtual host configuration
echo "Installing virtual host configuration..."
sudo cp "$SCRIPT_DIR/apache-virtualhost.conf" "$VHOST_FILE"

# Enable required Apache modules
echo "Enabling required Apache modules..."
sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2enmod headers
sudo a2enmod deflate
sudo a2enmod expires

# Enable the site
echo "Enabling site configuration..."
sudo a2ensite "$DOMAIN.conf"

# Disable default site (optional)
read -p "Do you want to disable the default Apache site? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo a2dissite 000-default.conf
    echo "✓ Default site disabled"
fi

# Test Apache configuration
echo "Testing Apache configuration..."
sudo apache2ctl configtest

# Reload Apache
echo "Reloading Apache..."
sudo systemctl reload apache2

echo ""
echo "✓ Apache configuration completed successfully!"
echo ""
echo "Next steps:"
echo "1. Ensure DNS records point to this server:"
echo "   - discernible.io -> your_server_ip"
echo "   - www.discernible.io -> your_server_ip"
echo "2. Run the certificate setup script to obtain SSL certificates"
echo "3. Copy your website files to /var/www/domains/$DOMAIN/public_html/"
