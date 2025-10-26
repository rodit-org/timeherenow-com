# SSL/TLS Certificate Setup Checklist for timeherenow.com

Use this checklist to ensure a smooth SSL certificate setup process.

## 📋 Pre-Setup Requirements

### DNS Configuration
- [ ] DNS A record created for `timeherenow.com` → server IP
- [ ] DNS A record created for `www.timeherenow.com` → server IP
- [ ] DNS propagation verified with `dig timeherenow.com`
- [ ] DNS propagation verified with `dig www.timeherenow.com`
- [ ] Both domains resolve to correct IP address

### Server Requirements
- [ ] Server is running Ubuntu/Debian Linux
- [ ] You have sudo/root access
- [ ] Server is accessible via SSH
- [ ] Server has internet connectivity

### Network Requirements
- [ ] Port 80 (HTTP) is open in firewall
- [ ] Port 443 (HTTPS) is open in firewall
- [ ] No other web server using port 80/443
- [ ] Server IP is publicly accessible

### Software Requirements
- [ ] System packages are up to date (`sudo apt update && sudo apt upgrade`)
- [ ] Sufficient disk space (at least 1GB free)
- [ ] Email address ready for Let's Encrypt notifications

## 🚀 Setup Process

### Step 1: Directory Structure
- [ ] Run `./setup-directories.sh`
- [ ] Verify `/var/www/domains/timeherenow.com/` exists
- [ ] Verify correct permissions (755)
- [ ] Verify correct ownership

### Step 2: Apache Configuration
- [ ] Run `./setup-apache.sh`
- [ ] Apache2 installed successfully
- [ ] Virtual host configuration created
- [ ] Required modules enabled (ssl, rewrite, headers, deflate, expires)
- [ ] Site configuration enabled
- [ ] Apache configuration test passed (`apache2ctl configtest`)
- [ ] Apache reloaded successfully

### Step 3: Website Deployment
- [ ] Run `./deploy-website.sh`
- [ ] Website files copied to document root
- [ ] Permissions set correctly (www-data:www-data)
- [ ] Can access http://timeherenow.com (may show default page)
- [ ] Can access http://www.timeherenow.com

### Step 4: SSL Certificate Acquisition
- [ ] Run `./setup-certificates.sh`
- [ ] Certbot installed successfully
- [ ] Email address provided for notifications
- [ ] Agreed to Let's Encrypt Terms of Service
- [ ] Certificates obtained for both domains
- [ ] Apache automatically configured for HTTPS
- [ ] HTTP to HTTPS redirect enabled
- [ ] Can access https://timeherenow.com
- [ ] Can access https://www.timeherenow.com
- [ ] No SSL certificate warnings in browser

### Step 5: Security Headers
- [ ] Run `./setup-security.sh`
- [ ] Security headers configuration installed
- [ ] Headers module enabled
- [ ] Configuration enabled
- [ ] Apache reloaded successfully
- [ ] Security headers present in HTTP response

### Step 6: Automated Management
- [ ] Run `./setup-cron.sh`
- [ ] Management scripts copied to `/usr/local/bin/`
- [ ] Scripts are executable
- [ ] Log files created
- [ ] Cron jobs configured
- [ ] Cron jobs visible with `sudo crontab -l`

## ✅ Post-Setup Verification

### Basic Functionality
- [ ] Website loads via HTTPS
- [ ] HTTP redirects to HTTPS
- [ ] No SSL/TLS errors in browser
- [ ] All website resources load correctly
- [ ] Website works on mobile devices

### Certificate Verification
- [ ] Run `./cert-test.sh` - all tests pass
- [ ] Certificate is valid (not expired)
- [ ] Certificate covers both domains
- [ ] Certificate issued by Let's Encrypt
- [ ] Certificate has 90-day validity

### Security Verification
- [ ] HSTS header present
- [ ] X-Frame-Options header present
- [ ] X-Content-Type-Options header present
- [ ] Referrer-Policy header present
- [ ] Content-Security-Policy header present
- [ ] Test at https://securityheaders.com/
- [ ] Test at https://www.ssllabs.com/ssltest/

### Automated Tasks
- [ ] Certificate renewal cron job configured
- [ ] Certificate monitoring cron job configured
- [ ] Backup cron job configured
- [ ] Test renewal with `sudo certbot renew --dry-run`

### Logs and Monitoring
- [ ] Apache error log accessible
- [ ] Apache access log accessible
- [ ] Certificate renewal log created
- [ ] Certificate monitor log created
- [ ] Backup log created

## 🧪 Testing Commands

Run these commands to verify everything is working:

```bash
# Test Apache configuration
sudo apache2ctl configtest

# Test HTTPS connectivity
curl -I https://timeherenow.com
curl -I https://www.timeherenow.com

# Test HTTP to HTTPS redirect
curl -I http://timeherenow.com

# View certificate details
sudo certbot certificates

# Test certificate renewal
sudo certbot renew --dry-run

# Run comprehensive tests
./cert-test.sh

# Check cron jobs
sudo crontab -l

# View recent logs
sudo tail -50 /var/log/cert-renewal.log
sudo tail -50 /var/www/domains/timeherenow.com/logs/error.log
```

## 🌐 Online Testing Tools

Test your SSL/TLS configuration:

- [ ] SSL Labs: https://www.ssllabs.com/ssltest/analyze.html?d=timeherenow.com
  - Target grade: A or A+
- [ ] Security Headers: https://securityheaders.com/?q=https://timeherenow.com
  - Target grade: A or higher
- [ ] Mozilla Observatory: https://observatory.mozilla.org/
- [ ] DNS Checker: https://dnschecker.org/#A/timeherenow.com

## 📊 Monitoring Schedule

Verify these automated tasks are running:

| Task | Frequency | Time | Log File |
|------|-----------|------|----------|
| Certificate Renewal | Daily | 2:30 AM | `/var/log/cert-renewal.log` |
| Certificate Monitoring | Daily | 8:00 AM | `/var/log/cert-monitor.log` |
| Backup | Weekly (Sunday) | 3:00 AM | `/var/log/cert-backup.log` |

## 🔧 Maintenance Tasks

### Weekly
- [ ] Check certificate expiry dates
- [ ] Review Apache error logs
- [ ] Verify website is accessible

### Monthly
- [ ] Test certificate renewal process
- [ ] Review security headers
- [ ] Check backup integrity
- [ ] Update system packages

### Quarterly
- [ ] Run full SSL/TLS tests
- [ ] Review and update security policies
- [ ] Test disaster recovery procedures
- [ ] Review and clean old backups

## 🆘 Troubleshooting Checklist

If something goes wrong:

- [ ] Check DNS resolution: `dig timeherenow.com`
- [ ] Check Apache status: `sudo systemctl status apache2`
- [ ] Check Apache config: `sudo apache2ctl configtest`
- [ ] Check ports: `sudo netstat -tlnp | grep -E ':(80|443)'`
- [ ] Check firewall: `sudo ufw status`
- [ ] Check certificate files: `sudo ls -l /etc/letsencrypt/live/timeherenow.com/`
- [ ] Check Apache logs: `sudo tail -100 /var/www/domains/timeherenow.com/logs/error.log`
- [ ] Check Certbot logs: `sudo tail -100 /var/log/letsencrypt/letsencrypt.log`

## 📝 Documentation

- [ ] README.md reviewed
- [ ] QUICKSTART.md reviewed
- [ ] DNS-SETUP.md reviewed
- [ ] All scripts have execute permissions
- [ ] Email address for notifications is correct
- [ ] Team members notified of new setup

## 🎉 Setup Complete!

Once all items are checked:

- [ ] Website is live and secure
- [ ] Certificates are valid and auto-renewing
- [ ] Monitoring is in place
- [ ] Backups are configured
- [ ] Documentation is complete

---

**Congratulations!** Your SSL/TLS certificate setup for timeherenow.com is complete and production-ready.

**Next Steps:**
1. Monitor logs for the first few days
2. Test certificate renewal after 60 days
3. Keep system and software updated
4. Review security best practices regularly

**Support:**
- See [README.md](README.md) for detailed documentation
- See [QUICKSTART.md](QUICKSTART.md) for quick commands
- See [DNS-SETUP.md](DNS-SETUP.md) for DNS configuration help
