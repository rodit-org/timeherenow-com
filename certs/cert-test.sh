#!/bin/bash
# Certificate Testing Script for timeherenow.com
# This script performs comprehensive SSL/TLS testing
# Location: /usr/local/bin/cert-test.sh

set -e

DOMAIN="timeherenow.com"

echo "=== Certificate Testing Suite ==="
echo "Domain: $DOMAIN"
echo "Date: $(date)"
echo ""

# Test 1: Apache Configuration
echo "1. Testing Apache Configuration"
echo "================================"
if sudo apache2ctl configtest 2>&1 | grep -q "Syntax OK"; then
    echo "✓ Apache configuration is valid"
else
    echo "✗ Apache configuration has errors"
    sudo apache2ctl configtest
fi
echo ""

# Test 2: HTTP to HTTPS Redirect
echo "2. Testing HTTP to HTTPS Redirect"
echo "=================================="
if command -v curl &> /dev/null; then
    echo "Testing: http://$DOMAIN"
    response=$(curl -sI "http://$DOMAIN" | head -n 1)
    echo "Response: $response"
    
    if curl -sI "http://$DOMAIN" | grep -q "301\|302"; then
        echo "✓ HTTP redirects to HTTPS"
    else
        echo "⚠ Warning: HTTP may not redirect to HTTPS"
    fi
else
    echo "⚠ curl not available, skipping redirect test"
fi
echo ""

# Test 3: HTTPS Connectivity
echo "3. Testing HTTPS Connectivity"
echo "=============================="
for subdomain in "$DOMAIN" "www.$DOMAIN"; do
    echo "Testing: https://$subdomain"
    
    if command -v curl &> /dev/null; then
        if timeout 10 curl -sI "https://$subdomain" > /dev/null 2>&1; then
            status=$(curl -sI "https://$subdomain" | head -n 1)
            echo "  Status: $status"
            echo "  ✓ HTTPS connection successful"
        else
            echo "  ✗ Cannot connect via HTTPS"
        fi
    fi
    echo ""
done

# Test 4: Certificate Details
echo "4. Certificate Details"
echo "======================"
for subdomain in "$DOMAIN" "www.$DOMAIN"; do
    echo "Certificate for: $subdomain"
    
    if command -v openssl &> /dev/null; then
        if timeout 5 bash -c "echo > /dev/tcp/$subdomain/443" 2>/dev/null; then
            cert_info=$(echo | openssl s_client -connect ${subdomain}:443 -servername ${subdomain} 2>/dev/null | openssl x509 -noout -dates -subject -issuer 2>/dev/null)
            
            if [ -n "$cert_info" ]; then
                echo "$cert_info" | while IFS= read -r line; do
                    echo "  $line"
                done
                echo "  ✓ Certificate retrieved successfully"
            else
                echo "  ✗ Could not retrieve certificate"
            fi
        else
            echo "  ✗ Cannot connect to $subdomain:443"
        fi
    else
        echo "  ⚠ OpenSSL not available"
    fi
    echo ""
done

# Test 5: SSL/TLS Protocol Support
echo "5. SSL/TLS Protocol Support"
echo "==========================="
if command -v openssl &> /dev/null; then
    for protocol in tls1_2 tls1_3; do
        echo -n "Testing $protocol: "
        if timeout 5 openssl s_client -connect ${DOMAIN}:443 -servername ${DOMAIN} -${protocol} </dev/null 2>&1 | grep -q "Cipher"; then
            echo "✓ Supported"
        else
            echo "✗ Not supported"
        fi
    done
else
    echo "⚠ OpenSSL not available"
fi
echo ""

# Test 6: Security Headers
echo "6. Security Headers Check"
echo "========================="
if command -v curl &> /dev/null; then
    echo "Checking security headers for https://$DOMAIN"
    headers=$(curl -sI "https://$DOMAIN" 2>/dev/null)
    
    check_header() {
        local header=$1
        if echo "$headers" | grep -qi "^$header:"; then
            echo "  ✓ $header: Present"
        else
            echo "  ✗ $header: Missing"
        fi
    }
    
    check_header "Strict-Transport-Security"
    check_header "X-Frame-Options"
    check_header "X-Content-Type-Options"
    check_header "Referrer-Policy"
    check_header "Content-Security-Policy"
else
    echo "⚠ curl not available"
fi
echo ""

# Test 7: Certificate Expiry Check
echo "7. Certificate Expiry Check"
echo "==========================="
cert_path="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
if [ -f "$cert_path" ]; then
    expiry_date=$(openssl x509 -enddate -noout -in "$cert_path" | cut -d= -f2)
    expiry_epoch=$(date -d "$expiry_date" +%s)
    current_epoch=$(date +%s)
    days_left=$(( ($expiry_epoch - $current_epoch) / 86400 ))
    
    echo "Certificate expires: $expiry_date"
    echo "Days remaining: $days_left"
    
    if [ $days_left -gt 30 ]; then
        echo "✓ Certificate is valid"
    elif [ $days_left -gt 0 ]; then
        echo "⚠ Warning: Certificate expires in less than 30 days"
    else
        echo "✗ Certificate has expired!"
    fi
else
    echo "⚠ Certificate file not found at $cert_path"
fi
echo ""

# Summary
echo "================================"
echo "Testing completed at $(date)"
echo "================================"
echo ""
echo "For detailed SSL/TLS analysis, use:"
echo "  - https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN"
echo "  - https://securityheaders.com/?q=https://$DOMAIN"
