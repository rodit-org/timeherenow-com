#!/bin/bash
# Cron Job Setup for Certificate Management
# This script sets up automated tasks for certificate renewal, monitoring, and backups

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Setting up automated certificate management tasks ==="
echo ""

# Copy scripts to /usr/local/bin
echo "Installing management scripts to /usr/local/bin..."
sudo cp "$SCRIPT_DIR/cert-renew-manager.sh" /usr/local/bin/
sudo cp "$SCRIPT_DIR/cert-monitor.sh" /usr/local/bin/
sudo cp "$SCRIPT_DIR/cert-backup.sh" /usr/local/bin/

# Make scripts executable
sudo chmod +x /usr/local/bin/cert-renew-manager.sh
sudo chmod +x /usr/local/bin/cert-monitor.sh
sudo chmod +x /usr/local/bin/cert-backup.sh

echo "✓ Scripts installed"
echo ""

# Create log directory
sudo mkdir -p /var/log
sudo touch /var/log/cert-renewal.log
sudo touch /var/log/cert-monitor.log
sudo touch /var/log/cert-backup.log

echo "✓ Log files created"
echo ""

# Setup cron jobs
echo "Setting up cron jobs..."

# Create temporary cron file
CRON_FILE=$(mktemp)

# Get existing cron jobs (if any)
sudo crontab -l > "$CRON_FILE" 2>/dev/null || true

# Add certificate management cron jobs if they don't exist
if ! grep -q "cert-renew-manager.sh" "$CRON_FILE"; then
    echo "" >> "$CRON_FILE"
    echo "# Certificate renewal check (daily at 2:30 AM)" >> "$CRON_FILE"
    echo "30 2 * * * /usr/local/bin/cert-renew-manager.sh >> /var/log/cert-renewal.log 2>&1" >> "$CRON_FILE"
fi

if ! grep -q "cert-monitor.sh" "$CRON_FILE"; then
    echo "" >> "$CRON_FILE"
    echo "# Certificate expiry monitoring (daily at 8:00 AM)" >> "$CRON_FILE"
    echo "0 8 * * * /usr/local/bin/cert-monitor.sh >> /var/log/cert-monitor.log 2>&1" >> "$CRON_FILE"
fi

if ! grep -q "cert-backup.sh" "$CRON_FILE"; then
    echo "" >> "$CRON_FILE"
    echo "# Certificate and configuration backup (weekly on Sunday at 3:00 AM)" >> "$CRON_FILE"
    echo "0 3 * * 0 /usr/local/bin/cert-backup.sh >> /var/log/cert-backup.log 2>&1" >> "$CRON_FILE"
fi

# Install new crontab
sudo crontab "$CRON_FILE"

# Clean up
rm "$CRON_FILE"

echo "✓ Cron jobs configured"
echo ""
echo "Scheduled tasks:"
echo "  - Certificate renewal: Daily at 2:30 AM"
echo "  - Certificate monitoring: Daily at 8:00 AM"
echo "  - Backup: Weekly on Sunday at 3:00 AM"
echo ""
echo "View cron jobs with: sudo crontab -l"
echo "View logs in: /var/log/cert-*.log"
