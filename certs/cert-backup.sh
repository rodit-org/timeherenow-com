#!/bin/bash
# Certificate Backup Script for discernible.io
# This script backs up all certificates and Apache configurations
# Location: /usr/local/bin/cert-backup.sh

set -e

BACKUP_BASE_DIR="/root/cert-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE_DIR/$TIMESTAMP"
DOMAIN="discernible.io"
LOG_FILE="/var/log/cert-backup.log"

echo "=== Certificate Backup ===" | tee -a "$LOG_FILE"
echo "Date: $(date)" | tee -a "$LOG_FILE"
echo "Backup directory: $BACKUP_DIR" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Create backup directory
echo "Creating backup directory..." | tee -a "$LOG_FILE"
sudo mkdir -p "$BACKUP_DIR"

# Backup Let's Encrypt certificates
if [ -d "/etc/letsencrypt" ]; then
    echo "Backing up Let's Encrypt certificates..." | tee -a "$LOG_FILE"
    sudo cp -r /etc/letsencrypt "$BACKUP_DIR/"
    echo "✓ Certificates backed up" | tee -a "$LOG_FILE"
else
    echo "⚠ Warning: /etc/letsencrypt not found" | tee -a "$LOG_FILE"
fi

# Backup Apache configurations
if [ -d "/etc/apache2/sites-available" ]; then
    echo "Backing up Apache site configurations..." | tee -a "$LOG_FILE"
    sudo cp -r /etc/apache2/sites-available "$BACKUP_DIR/"
    echo "✓ Apache sites backed up" | tee -a "$LOG_FILE"
else
    echo "⚠ Warning: /etc/apache2/sites-available not found" | tee -a "$LOG_FILE"
fi

if [ -d "/etc/apache2/conf-available" ]; then
    echo "Backing up Apache conf configurations..." | tee -a "$LOG_FILE"
    sudo cp -r /etc/apache2/conf-available "$BACKUP_DIR/"
    echo "✓ Apache conf backed up" | tee -a "$LOG_FILE"
fi

# Backup website files
if [ -d "/var/www/domains/$DOMAIN" ]; then
    echo "Backing up website files..." | tee -a "$LOG_FILE"
    sudo cp -r "/var/www/domains/$DOMAIN" "$BACKUP_DIR/"
    echo "✓ Website files backed up" | tee -a "$LOG_FILE"
fi

# Create archive
echo "Creating compressed archive..." | tee -a "$LOG_FILE"
ARCHIVE_FILE="$BACKUP_BASE_DIR/backup_$TIMESTAMP.tar.gz"
sudo tar -czf "$ARCHIVE_FILE" -C "$BACKUP_BASE_DIR" "$TIMESTAMP"
echo "✓ Archive created: $ARCHIVE_FILE" | tee -a "$LOG_FILE"

# Remove uncompressed backup directory
echo "Cleaning up..." | tee -a "$LOG_FILE"
sudo rm -rf "$BACKUP_DIR"

# Get archive size
ARCHIVE_SIZE=$(du -h "$ARCHIVE_FILE" | cut -f1)
echo "✓ Backup completed successfully!" | tee -a "$LOG_FILE"
echo "Archive size: $ARCHIVE_SIZE" | tee -a "$LOG_FILE"

# Clean up old backups (keep last 30 days)
echo "" | tee -a "$LOG_FILE"
echo "Cleaning up old backups (keeping last 30 days)..." | tee -a "$LOG_FILE"
sudo find "$BACKUP_BASE_DIR" -name "backup_*.tar.gz" -type f -mtime +30 -delete
echo "✓ Old backups cleaned up" | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "Backup completed at $(date)" | tee -a "$LOG_FILE"
echo "----------------------------------------" | tee -a "$LOG_FILE"
