#!/bin/bash
# Directory Structure Setup for timeherenow.com
# This script creates the necessary directory structure for hosting the website

set -e

DOMAIN="timeherenow.com"
BASE_DIR="/var/www/domains"

echo "=== Setting up directory structure for $DOMAIN ==="

# Create base directories
echo "Creating base directories..."
sudo mkdir -p "$BASE_DIR"

# Create domain-specific directories
echo "Creating domain directories for $DOMAIN..."
sudo mkdir -p "$BASE_DIR/$DOMAIN/public_html"
sudo mkdir -p "$BASE_DIR/$DOMAIN/logs"

# Set ownership
echo "Setting ownership..."
sudo chown -R $USER:$USER "$BASE_DIR/$DOMAIN"

# Set permissions
echo "Setting permissions..."
sudo chmod -R 755 "$BASE_DIR/$DOMAIN"

echo "✓ Directory structure created successfully!"
echo ""
echo "Directory layout:"
echo "$BASE_DIR/$DOMAIN/"
echo "├── public_html/  (web root)"
echo "└── logs/         (Apache logs)"
echo ""
echo "Next steps:"
echo "1. Copy your website files to $BASE_DIR/$DOMAIN/public_html/"
echo "2. Configure Apache virtual hosts"
echo "3. Obtain SSL certificates"
