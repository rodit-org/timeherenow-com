#!/bin/bash
# Certificate Renewal Manager for discernible.io
# This script manages certificate renewal and checks expiry dates
# Location: /usr/local/bin/cert-renew-manager.sh

set -e

DOMAIN="discernible.io"
LOG_FILE="/var/log/cert-renewal.log"

echo "=== Certificate Renewal Manager ===" | tee -a "$LOG_FILE"
echo "Date: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Renew all certificates
echo "Attempting to renew certificates..." | tee -a "$LOG_FILE"
if sudo certbot renew --quiet; then
    echo "✓ Certificate renewal check completed" | tee -a "$LOG_FILE"
else
    echo "✗ Certificate renewal failed" | tee -a "$LOG_FILE"
    exit 1
fi

# Check renewal status for the domain
cert_path="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"

if [ -f "$cert_path" ]; then
    expiry_date=$(openssl x509 -enddate -noout -in "$cert_path" | cut -d= -f2)
    expiry_epoch=$(date -d "$expiry_date" +%s)
    current_epoch=$(date +%s)
    days_left=$(( ($expiry_epoch - $current_epoch) / 86400 ))
    
    echo "Domain: $DOMAIN" | tee -a "$LOG_FILE"
    echo "Certificate expires: $expiry_date" | tee -a "$LOG_FILE"
    echo "Days remaining: $days_left" | tee -a "$LOG_FILE"
    
    if [ $days_left -lt 30 ]; then
        echo "⚠ WARNING: Certificate expires in less than 30 days!" | tee -a "$LOG_FILE"
    else
        echo "✓ Certificate is valid" | tee -a "$LOG_FILE"
    fi
else
    echo "✗ Warning: No certificate found for $DOMAIN" | tee -a "$LOG_FILE"
    exit 1
fi

echo "" | tee -a "$LOG_FILE"
echo "Renewal check completed at $(date)" | tee -a "$LOG_FILE"
echo "----------------------------------------" | tee -a "$LOG_FILE"
