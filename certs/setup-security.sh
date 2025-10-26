#!/bin/bash
# Security Configuration Setup for Apache
# This script applies security headers to all sites

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECURITY_CONF="/etc/apache2/conf-available/security-headers.conf"

echo "=== Setting up security headers ==="

# Copy security headers configuration
echo "Installing security headers configuration..."
sudo cp "$SCRIPT_DIR/security-headers.conf" "$SECURITY_CONF"

# Enable headers module if not already enabled
echo "Enabling headers module..."
sudo a2enmod headers

# Enable security headers configuration
echo "Enabling security headers configuration..."
sudo a2enconf security-headers

# Test Apache configuration
echo "Testing Apache configuration..."
sudo apache2ctl configtest

# Reload Apache
echo "Reloading Apache..."
sudo systemctl reload apache2

echo ""
echo "✓ Security headers configured successfully!"
echo ""
echo "Enabled security headers:"
echo "  - Strict-Transport-Security (HSTS)"
echo "  - X-Frame-Options"
echo "  - X-Content-Type-Options"
echo "  - X-XSS-Protection"
echo "  - Referrer-Policy"
echo "  - Content-Security-Policy"
echo "  - Permissions-Policy"
echo ""
echo "Test your security headers at: https://securityheaders.com/"
