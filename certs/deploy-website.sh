#!/bin/bash
# Website Deployment Script for timeherenow.com
# This script deploys the website files to the Apache document root

set -e

DOMAIN="timeherenow.com"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/public"
DEST_DIR="/var/www/domains/$DOMAIN/public_html"

echo "=== Website Deployment ==="
echo "Domain: $DOMAIN"
echo "Source: $SOURCE_DIR"
echo "Destination: $DEST_DIR"
echo ""

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "✗ Error: Source directory not found: $SOURCE_DIR"
    exit 1
fi

# Check if destination directory exists
if [ ! -d "$DEST_DIR" ]; then
    echo "⚠ Warning: Destination directory does not exist"
    echo "Creating destination directory..."
    sudo mkdir -p "$DEST_DIR"
fi

# Backup existing files if any
if [ "$(ls -A $DEST_DIR 2>/dev/null)" ]; then
    BACKUP_DIR="/var/www/domains/$DOMAIN/backups/$(date +%Y%m%d_%H%M%S)"
    echo "Backing up existing files to $BACKUP_DIR..."
    sudo mkdir -p "$BACKUP_DIR"
    sudo cp -r "$DEST_DIR"/* "$BACKUP_DIR/"
    echo "✓ Backup created"
fi

# Deploy website files
echo "Deploying website files..."
sudo cp -r "$SOURCE_DIR"/* "$DEST_DIR/"

# Set correct permissions
echo "Setting permissions..."
sudo chown -R www-data:www-data "$DEST_DIR"
sudo find "$DEST_DIR" -type d -exec chmod 755 {} \;
sudo find "$DEST_DIR" -type f -exec chmod 644 {} \;

echo ""
echo "✓ Website deployed successfully!"
echo ""
echo "Deployed files:"
ls -lh "$DEST_DIR"
echo ""
echo "Your website should now be accessible at:"
echo "  - https://$DOMAIN"
echo "  - https://www.$DOMAIN"
