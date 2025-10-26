#!/bin/bash
# Master Setup Script for timeherenow.com SSL/TLS Certificates
# This script runs all setup steps in the correct order

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   SSL/TLS Certificate Setup for timeherenow.com            ║"
echo "║   Complete Apache2 + Let's Encrypt Configuration          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Function to run a script with error handling
run_step() {
    local script=$1
    local description=$2
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $description"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [ -f "$SCRIPT_DIR/$script" ]; then
        chmod +x "$SCRIPT_DIR/$script"
        if "$SCRIPT_DIR/$script"; then
            echo ""
            echo "✓ $description completed successfully"
        else
            echo ""
            echo "✗ $description failed"
            read -p "Continue anyway? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    else
        echo "✗ Script not found: $script"
        exit 1
    fi
}

# Confirmation
echo "This script will:"
echo "  1. Create directory structure"
echo "  2. Configure Apache web server"
echo "  3. Deploy website files"
echo "  4. Obtain SSL certificates from Let's Encrypt"
echo "  5. Configure security headers"
echo "  6. Setup automated management tasks"
echo ""
echo "Prerequisites:"
echo "  - DNS records must point to this server"
echo "  - Ports 80 and 443 must be open"
echo "  - You must have sudo privileges"
echo ""
read -p "Do you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled"
    exit 0
fi

# Step 1: Directory Structure
run_step "setup-directories.sh" "Step 1/6: Setting up directory structure"

# Step 2: Apache Configuration
run_step "setup-apache.sh" "Step 2/6: Configuring Apache web server"

# Step 3: Deploy Website
run_step "deploy-website.sh" "Step 3/6: Deploying website files"

# Step 4: SSL Certificates
run_step "setup-certificates.sh" "Step 4/6: Obtaining SSL certificates"

# Step 5: Security Headers
run_step "setup-security.sh" "Step 5/6: Configuring security headers"

# Step 6: Automated Management
run_step "setup-cron.sh" "Step 6/6: Setting up automated management"

# Final Summary
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              SETUP COMPLETED SUCCESSFULLY!                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Your website is now configured with SSL/TLS certificates!"
echo ""
echo "🌐 Website URLs:"
echo "   https://timeherenow.com"
echo "   https://www.timeherenow.com"
echo ""
echo "📁 Website Location:"
echo "   /var/www/domains/timeherenow.com/public_html/"
echo ""
echo "🔐 Certificate Location:"
echo "   /etc/letsencrypt/live/timeherenow.com/"
echo ""
echo "📊 Automated Tasks:"
echo "   - Certificate renewal: Daily at 2:30 AM"
echo "   - Certificate monitoring: Daily at 8:00 AM"
echo "   - Backups: Weekly on Sunday at 3:00 AM"
echo ""
echo "📝 Logs:"
echo "   - /var/log/cert-renewal.log"
echo "   - /var/log/cert-monitor.log"
echo "   - /var/log/cert-backup.log"
echo "   - /var/www/domains/timeherenow.com/logs/"
echo ""
echo "🧪 Test Your Setup:"
echo "   ./cert-test.sh"
echo "   https://www.ssllabs.com/ssltest/analyze.html?d=timeherenow.com"
echo "   https://securityheaders.com/?q=https://timeherenow.com"
echo ""
echo "📖 For more information, see: README.md"
echo ""
