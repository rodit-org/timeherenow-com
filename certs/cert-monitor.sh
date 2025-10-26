#!/bin/bash
# Certificate Monitoring Script for timeherenow.com
# This script monitors certificate expiry and sends notifications
# Location: /usr/local/bin/cert-monitor.sh

set -e

DOMAIN="timeherenow.com"
NOTIFICATION_EMAIL="admin@timeherenow.com"
WARNING_DAYS=30
LOG_FILE="/var/log/cert-monitor.log"

echo "=== Certificate Monitor ===" | tee -a "$LOG_FILE"
echo "Date: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Function to check certificate expiry
check_certificate() {
    local domain=$1
    
    echo "Checking certificate for $domain..." | tee -a "$LOG_FILE"
    
    # Try to get certificate expiry from the live certificate
    if command -v openssl &> /dev/null; then
        # Check if the domain is accessible
        if timeout 5 bash -c "echo > /dev/tcp/$domain/443" 2>/dev/null; then
            expiry=$(echo | openssl s_client -connect ${domain}:443 -servername ${domain} 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
            
            if [ -n "$expiry" ]; then
                expiry_epoch=$(date -d "$expiry" +%s)
                current_epoch=$(date +%s)
                days_left=$(( ($expiry_epoch - $current_epoch) / 86400 ))
                
                echo "  Domain: $domain" | tee -a "$LOG_FILE"
                echo "  Expires: $expiry" | tee -a "$LOG_FILE"
                echo "  Days remaining: $days_left" | tee -a "$LOG_FILE"
                
                if [ $days_left -lt $WARNING_DAYS ]; then
                    message="⚠ WARNING: Certificate for $domain expires in $days_left days (on $expiry)"
                    echo "$message" | tee -a "$LOG_FILE"
                    
                    # Send email notification if mail is available
                    if command -v mail &> /dev/null; then
                        echo "$message" | mail -s "Certificate Expiry Warning: $domain" "$NOTIFICATION_EMAIL"
                        echo "  Email notification sent to $NOTIFICATION_EMAIL" | tee -a "$LOG_FILE"
                    else
                        echo "  Warning: 'mail' command not available, cannot send email notification" | tee -a "$LOG_FILE"
                    fi
                else
                    echo "  ✓ Certificate is valid" | tee -a "$LOG_FILE"
                fi
            else
                echo "  ✗ Could not retrieve certificate expiry date" | tee -a "$LOG_FILE"
            fi
        else
            echo "  ✗ Cannot connect to $domain:443" | tee -a "$LOG_FILE"
        fi
    else
        echo "  ✗ OpenSSL not available" | tee -a "$LOG_FILE"
    fi
    
    echo "" | tee -a "$LOG_FILE"
}

# Check main domain and www subdomain
check_certificate "$DOMAIN"
check_certificate "www.$DOMAIN"

echo "Monitor check completed at $(date)" | tee -a "$LOG_FILE"
echo "----------------------------------------" | tee -a "$LOG_FILE"
