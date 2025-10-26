# SSL/TLS Certificate Setup for www.timeherenow.com

This directory contains comprehensive scripts and configurations for setting up and managing SSL/TLS certificates for **timeherenow.com** using Apache2 and Let's Encrypt.

## 📋 Prerequisites

Before running these scripts, ensure:

1. **DNS Records are configured:**
   ```
   timeherenow.com      A    -> your_server_ip
   www.timeherenow.com  A    -> your_server_ip
   ```

2. **Server requirements:**
   - Ubuntu/Debian-based Linux system
   - Root or sudo access
   - Port 80 and 443 open in firewall
   - Domain pointing to your server

## 🚀 Quick Start

Follow these steps in order to set up SSL certificates:

### Step 1: Setup Directory Structure
```bash
chmod +x setup-directories.sh
./setup-directories.sh
```
This creates the necessary directory structure at `/var/www/domains/timeherenow.com/`

### Step 2: Configure Apache
```bash
chmod +x setup-apache.sh
./setup-apache.sh
```
This installs and configures Apache with the virtual host for your domain.

### Step 3: Deploy Website Files
```bash
chmod +x deploy-website.sh
./deploy-website.sh
```
This copies your website files from the `public/` directory to the Apache document root.

### Step 4: Obtain SSL Certificates
```bash
chmod +x setup-certificates.sh
./setup-certificates.sh
```
This installs Certbot and obtains SSL certificates from Let's Encrypt. You'll be prompted for:
- Email address for certificate notifications
- Agreement to Let's Encrypt Terms of Service

### Step 5: Configure Security Headers
```bash
chmod +x setup-security.sh
./setup-security.sh
```
This applies security headers (HSTS, CSP, X-Frame-Options, etc.) to your site.

### Step 6: Setup Automated Management
```bash
chmod +x setup-cron.sh
./setup-cron.sh
```
This sets up automated tasks for:
- Certificate renewal (daily at 2:30 AM)
- Certificate monitoring (daily at 8:00 AM)
- Backups (weekly on Sunday at 3:00 AM)

## 📁 Files Overview

### Configuration Files
- **`apache-virtualhost.conf`** - Apache virtual host configuration
- **`security-headers.conf`** - Security headers configuration
- **`domains.txt`** - List of domains for certificate management

### Setup Scripts
- **`setup-directories.sh`** - Creates directory structure
- **`setup-apache.sh`** - Configures Apache web server
- **`setup-certificates.sh`** - Obtains SSL certificates
- **`setup-security.sh`** - Applies security headers
- **`setup-cron.sh`** - Sets up automated tasks
- **`deploy-website.sh`** - Deploys website files

### Management Scripts
- **`cert-renew-manager.sh`** - Manages certificate renewal
- **`cert-monitor.sh`** - Monitors certificate expiry
- **`cert-backup.sh`** - Backs up certificates and configurations
- **`cert-test.sh`** - Tests SSL/TLS configuration

## 🔧 Manual Operations

### Test Certificate Renewal
```bash
sudo certbot renew --dry-run
```

### View Certificate Details
```bash
sudo certbot certificates
```

### Manually Renew Certificates
```bash
sudo certbot renew
```

### Run Certificate Tests
```bash
chmod +x cert-test.sh
./cert-test.sh
```

### Manual Backup
```bash
sudo /usr/local/bin/cert-backup.sh
```

### Check Certificate Expiry
```bash
sudo /usr/local/bin/cert-monitor.sh
```

## 📊 Monitoring

### View Logs
```bash
# Certificate renewal log
sudo tail -f /var/log/cert-renewal.log

# Certificate monitoring log
sudo tail -f /var/log/cert-monitor.log

# Backup log
sudo tail -f /var/log/cert-backup.log

# Apache error log
sudo tail -f /var/www/domains/timeherenow.com/logs/error.log

# Apache access log
sudo tail -f /var/www/domains/timeherenow.com/logs/access.log
```

### View Cron Jobs
```bash
sudo crontab -l
```

## 🔒 Security Features

The setup includes:

- **HSTS (HTTP Strict Transport Security)** - Forces HTTPS connections
- **X-Frame-Options** - Prevents clickjacking
- **X-Content-Type-Options** - Prevents MIME sniffing
- **X-XSS-Protection** - Enables XSS filtering
- **Referrer-Policy** - Controls referrer information
- **Content-Security-Policy** - Restricts resource loading
- **Permissions-Policy** - Controls browser features

## 🧪 Testing Your Setup

### Online Testing Tools
1. **SSL Labs**: https://www.ssllabs.com/ssltest/analyze.html?d=timeherenow.com
2. **Security Headers**: https://securityheaders.com/?q=https://timeherenow.com
3. **Mozilla Observatory**: https://observatory.mozilla.org/

### Local Testing
```bash
# Test HTTPS connectivity
curl -I https://timeherenow.com

# Test HTTP to HTTPS redirect
curl -I http://timeherenow.com

# Check certificate details
openssl s_client -connect timeherenow.com:443 -servername timeherenow.com < /dev/null

# Run comprehensive tests
./cert-test.sh
```

## 🔄 Certificate Renewal

Certificates are automatically renewed by:
1. **Certbot's systemd timer** (built-in)
2. **Custom renewal manager** (daily at 2:30 AM via cron)

Both methods ensure your certificates stay valid.

## 💾 Backups

Backups are stored in `/root/cert-backups/` and include:
- Let's Encrypt certificates
- Apache configurations
- Website files

Backups are:
- Created weekly (Sunday at 3:00 AM)
- Compressed as `.tar.gz` files
- Automatically cleaned up after 30 days

### Restore from Backup
```bash
# List available backups
ls -lh /root/cert-backups/

# Extract a backup
sudo tar -xzf /root/cert-backups/backup_YYYYMMDD_HHMMSS.tar.gz -C /tmp/

# Restore certificates
sudo cp -r /tmp/YYYYMMDD_HHMMSS/letsencrypt/* /etc/letsencrypt/

# Restart Apache
sudo systemctl restart apache2
```

## 🛠️ Troubleshooting

### Certificate Not Obtained
```bash
# Check if port 80 is accessible
sudo netstat -tlnp | grep :80

# Check Apache status
sudo systemctl status apache2

# Check Apache configuration
sudo apache2ctl configtest

# Check DNS resolution
dig timeherenow.com
dig www.timeherenow.com
```

### HTTPS Not Working
```bash
# Check if port 443 is open
sudo netstat -tlnp | grep :443

# Check SSL module is enabled
sudo apache2ctl -M | grep ssl

# Check certificate files exist
sudo ls -l /etc/letsencrypt/live/timeherenow.com/
```

### Renewal Fails
```bash
# Check renewal logs
sudo tail -100 /var/log/letsencrypt/letsencrypt.log

# Test renewal manually
sudo certbot renew --dry-run

# Force renewal (if certificate is close to expiry)
sudo certbot renew --force-renewal
```

## 📞 Support Resources

- **Let's Encrypt Documentation**: https://letsencrypt.org/docs/
- **Certbot Documentation**: https://certbot.eff.org/docs/
- **Apache Documentation**: https://httpd.apache.org/docs/

## 📝 Notes

- Certificates are valid for 90 days
- Automatic renewal occurs when certificates have 30 days or less remaining
- All scripts log their activities for audit purposes
- Email notifications are sent when certificates are close to expiry
- Backups are kept for 30 days before automatic deletion

## 🔐 Security Best Practices

1. **Keep software updated:**
   ```bash
   sudo apt update && sudo apt upgrade
   ```

2. **Monitor logs regularly:**
   ```bash
   sudo tail -f /var/log/apache2/error.log
   ```

3. **Test SSL configuration periodically:**
   ```bash
   ./cert-test.sh
   ```

4. **Review security headers:**
   ```bash
   curl -I https://timeherenow.com
   ```

5. **Keep backups off-site** - Consider copying backups to a remote location

## 📄 License

These scripts are provided as-is for managing SSL/TLS certificates for timeherenow.com.

---

**Last Updated:** 2025-10-16
**Domain:** timeherenow.com, www.timeherenow.com
**Web Server:** Apache2
**Certificate Authority:** Let's Encrypt
