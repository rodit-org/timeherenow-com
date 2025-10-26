# Quick Start Guide - SSL/TLS Setup for timeherenow.com

## 🚀 One-Command Setup

Run everything automatically:
```bash
cd /home/icarus40/homepage-timeherenow-com/certs
./setup-all.sh
```

## 📋 Step-by-Step Setup

If you prefer to run steps individually:

### 1. Create Directories
```bash
./setup-directories.sh
```

### 2. Configure Apache
```bash
./setup-apache.sh
```

### 3. Deploy Website
```bash
./deploy-website.sh
```

### 4. Get SSL Certificates
```bash
./setup-certificates.sh
```

### 5. Add Security Headers
```bash
./setup-security.sh
```

### 6. Setup Automation
```bash
./setup-cron.sh
```

## ✅ Verify Setup

Test everything is working:
```bash
./cert-test.sh
```

## 🌐 Access Your Site

After setup, visit:
- https://timeherenow.com
- https://www.timeherenow.com

## 📊 Check Certificate Status

```bash
sudo certbot certificates
```

## 🔄 Manual Certificate Renewal

```bash
sudo certbot renew
```

## 📝 View Logs

```bash
# Certificate renewal
sudo tail -f /var/log/cert-renewal.log

# Certificate monitoring
sudo tail -f /var/log/cert-monitor.log

# Backups
sudo tail -f /var/log/cert-backup.log

# Apache errors
sudo tail -f /var/www/domains/timeherenow.com/logs/error.log
```

## 🆘 Troubleshooting

### Apache won't start
```bash
sudo apache2ctl configtest
sudo systemctl status apache2
```

### Certificate not obtained
```bash
# Check DNS
dig timeherenow.com
dig www.timeherenow.com

# Check ports
sudo netstat -tlnp | grep -E ':(80|443)'

# Check Certbot logs
sudo tail -100 /var/log/letsencrypt/letsencrypt.log
```

### Website not accessible
```bash
# Check Apache is running
sudo systemctl status apache2

# Restart Apache
sudo systemctl restart apache2

# Check firewall
sudo ufw status
```

## 🔐 Important Files

| File | Location |
|------|----------|
| Website files | `/var/www/domains/timeherenow.com/public_html/` |
| Certificates | `/etc/letsencrypt/live/timeherenow.com/` |
| Apache config | `/etc/apache2/sites-available/timeherenow.com.conf` |
| Security headers | `/etc/apache2/conf-available/security-headers.conf` |

## 📞 Need Help?

See the full [README.md](README.md) for detailed documentation.

---

**Quick Commands Reference:**

```bash
# Test SSL configuration
./cert-test.sh

# Manual backup
sudo /usr/local/bin/cert-backup.sh

# Check certificate expiry
sudo /usr/local/bin/cert-monitor.sh

# Renew certificates
sudo /usr/local/bin/cert-renew-manager.sh

# View cron jobs
sudo crontab -l

# Restart Apache
sudo systemctl restart apache2
```
