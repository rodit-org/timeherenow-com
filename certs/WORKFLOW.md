# SSL/TLS Certificate Setup Workflow

## 📊 Visual Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    BEFORE YOU START                             │
├─────────────────────────────────────────────────────────────────┤
│  1. Configure DNS Records                                       │
│     discernible.io → your_server_ip                            │
│     www.discernible.io → your_server_ip                        │
│                                                                  │
│  2. Verify DNS Propagation                                      │
│     dig discernible.io                                          │
│     dig www.discernible.io                                      │
│                                                                  │
│  3. Ensure Ports Open                                           │
│     Port 80 (HTTP) - for certificate validation                │
│     Port 443 (HTTPS) - for secure connections                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    AUTOMATED SETUP                              │
│                   ./setup-all.sh                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Step 1: Directory Structure                                    │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ ./setup-directories.sh                                  │   │
│  │ Creates: /var/www/domains/discernible.io/             │   │
│  │          ├── public_html/                              │   │
│  │          └── logs/                                     │   │
│  └────────────────────────────────────────────────────────┘   │
│                         ↓                                       │
│  Step 2: Apache Configuration                                   │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ ./setup-apache.sh                                       │   │
│  │ - Installs Apache2                                      │   │
│  │ - Configures virtual host                               │   │
│  │ - Enables required modules                              │   │
│  │ - Enables site configuration                            │   │
│  └────────────────────────────────────────────────────────┘   │
│                         ↓                                       │
│  Step 3: Website Deployment                                     │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ ./deploy-website.sh                                     │   │
│  │ Copies: public/* → /var/www/domains/.../public_html/  │   │
│  │ Sets correct permissions and ownership                  │   │
│  └────────────────────────────────────────────────────────┘   │
│                         ↓                                       │
│  Step 4: SSL Certificate Acquisition                            │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ ./setup-certificates.sh                                 │   │
│  │ - Installs Certbot                                      │   │
│  │ - Obtains certificates from Let's Encrypt              │   │
│  │ - Auto-configures Apache for HTTPS                     │   │
│  │ - Enables HTTP → HTTPS redirect                        │   │
│  └────────────────────────────────────────────────────────┘   │
│                         ↓                                       │
│  Step 5: Security Headers                                       │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ ./setup-security.sh                                     │   │
│  │ Applies: HSTS, CSP, X-Frame-Options, etc.             │   │
│  └────────────────────────────────────────────────────────┘   │
│                         ↓                                       │
│  Step 6: Automated Management                                   │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ ./setup-cron.sh                                         │   │
│  │ Schedules:                                              │   │
│  │ - Certificate renewal (daily 2:30 AM)                  │   │
│  │ - Certificate monitoring (daily 8:00 AM)               │   │
│  │ - Backups (weekly Sunday 3:00 AM)                      │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    VERIFICATION                                 │
├─────────────────────────────────────────────────────────────────┤
│  ./cert-test.sh                                                 │
│  ✓ Apache configuration valid                                  │
│  ✓ HTTP redirects to HTTPS                                     │
│  ✓ HTTPS connectivity working                                  │
│  ✓ Certificate valid and trusted                               │
│  ✓ Security headers present                                    │
│  ✓ TLS 1.2/1.3 supported                                       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    ONGOING OPERATIONS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Daily (2:30 AM)                                                │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ cert-renew-manager.sh                                   │   │
│  │ - Checks certificate expiry                             │   │
│  │ - Renews if < 30 days remaining                        │   │
│  │ - Logs renewal status                                   │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                  │
│  Daily (8:00 AM)                                                │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ cert-monitor.sh                                         │   │
│  │ - Monitors certificate expiry                           │   │
│  │ - Sends email if < 30 days                             │   │
│  │ - Logs monitoring results                               │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                  │
│  Weekly (Sunday 3:00 AM)                                        │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ cert-backup.sh                                          │   │
│  │ - Backs up certificates                                 │   │
│  │ - Backs up Apache configs                               │   │
│  │ - Backs up website files                                │   │
│  │ - Creates compressed archive                            │   │
│  │ - Cleans up old backups (>30 days)                     │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Certificate Lifecycle

```
Day 0: Certificate Issued
│      Valid for 90 days
│      
│      ┌─────────────────────────────────────┐
│      │     Certificate Active Period       │
│      │         (Days 0-60)                 │
│      │   ✓ Certificate fully valid         │
│      │   ✓ No action needed                │
│      └─────────────────────────────────────┘
│
Day 60: Renewal Window Opens
│       
│       ┌─────────────────────────────────────┐
│       │    Auto-Renewal Period              │
│       │        (Days 60-90)                 │
│       │   🔄 Daily renewal attempts         │
│       │   📧 Monitoring active              │
│       └─────────────────────────────────────┘
│
Day 60-89: Automatic Renewal
│          Certbot attempts renewal daily
│          Success → New 90-day certificate
│          
Day 90: Certificate Expires
        (Should never reach here with automation)
```

## 📁 File Structure After Setup

```
Server File System
│
├── /var/www/domains/discernible.io/
│   ├── public_html/
│   │   ├── index.html
│   │   ├── styles.css
│   │   └── script.js
│   ├── logs/
│   │   ├── access.log
│   │   └── error.log
│   └── backups/
│       └── (deployment backups)
│
├── /etc/letsencrypt/
│   ├── live/discernible.io/
│   │   ├── fullchain.pem    (Certificate + Chain)
│   │   ├── privkey.pem      (Private Key)
│   │   ├── cert.pem         (Certificate Only)
│   │   └── chain.pem        (Chain Only)
│   ├── renewal/
│   │   └── discernible.io.conf
│   └── archive/
│       └── discernible.io/
│
├── /etc/apache2/
│   ├── sites-available/
│   │   └── discernible.io.conf
│   ├── sites-enabled/
│   │   └── discernible.io.conf → ../sites-available/
│   └── conf-available/
│       └── security-headers.conf
│
├── /usr/local/bin/
│   ├── cert-renew-manager.sh
│   ├── cert-monitor.sh
│   └── cert-backup.sh
│
├── /var/log/
│   ├── cert-renewal.log
│   ├── cert-monitor.log
│   └── cert-backup.log
│
└── /root/cert-backups/
    ├── backup_20251016_030000.tar.gz
    ├── backup_20251023_030000.tar.gz
    └── backup_20251030_030000.tar.gz
```

## 🎯 Decision Tree

```
Need SSL Certificate?
│
├─ YES → Have DNS configured?
│        │
│        ├─ YES → Have server access?
│        │        │
│        │        ├─ YES → Run ./setup-all.sh
│        │        │        │
│        │        │        ├─ Success → ✓ Done!
│        │        │        │            Monitor logs
│        │        │        │            
│        │        │        └─ Failed → Check:
│        │        │                    - DNS propagation
│        │        │                    - Ports 80/443 open
│        │        │                    - Apache logs
│        │        │                    - Certbot logs
│        │        │
│        │        └─ NO → Get server access first
│        │
│        └─ NO → Configure DNS first
│                 See: DNS-SETUP.md
│
└─ NO → Use Digital Ocean App Platform
         (automatic SSL included)
```

## 🛠️ Troubleshooting Flow

```
Problem Detected
│
├─ Website not loading?
│  │
│  ├─ Check Apache: systemctl status apache2
│  ├─ Check config: apache2ctl configtest
│  ├─ Check logs: tail -f /var/www/.../logs/error.log
│  └─ Restart: systemctl restart apache2
│
├─ Certificate not obtained?
│  │
│  ├─ Check DNS: dig discernible.io
│  ├─ Check ports: netstat -tlnp | grep -E ':(80|443)'
│  ├─ Check Certbot logs: tail -f /var/log/letsencrypt/letsencrypt.log
│  └─ Try manual: certbot --apache -d discernible.io -d www.discernible.io
│
├─ HTTPS not working?
│  │
│  ├─ Check certificate: certbot certificates
│  ├─ Check SSL module: apache2ctl -M | grep ssl
│  ├─ Check virtual host: cat /etc/apache2/sites-enabled/discernible.io.conf
│  └─ Check firewall: ufw status
│
└─ Renewal failing?
   │
   ├─ Test renewal: certbot renew --dry-run
   ├─ Check renewal config: cat /etc/letsencrypt/renewal/discernible.io.conf
   ├─ Check cron: crontab -l
   └─ Force renewal: certbot renew --force-renewal
```

## 📊 Monitoring Dashboard (Conceptual)

```
╔══════════════════════════════════════════════════════════════╗
║              SSL/TLS Certificate Status                      ║
╠══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Domain: discernible.io                                      ║
║  Status: ✓ Active                                            ║
║  Expires: 2026-01-14 (90 days remaining)                    ║
║  Issuer: Let's Encrypt                                       ║
║  Grade: A+                                                   ║
║                                                               ║
║  Domain: www.discernible.io                                  ║
║  Status: ✓ Active                                            ║
║  Expires: 2026-01-14 (90 days remaining)                    ║
║  Issuer: Let's Encrypt                                       ║
║  Grade: A+                                                   ║
║                                                               ║
╠══════════════════════════════════════════════════════════════╣
║              Automated Tasks Status                          ║
╠══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Certificate Renewal:    ✓ Scheduled (Daily 2:30 AM)        ║
║  Last Run: 2025-10-16 02:30:00                              ║
║  Status: Success                                             ║
║                                                               ║
║  Certificate Monitor:    ✓ Scheduled (Daily 8:00 AM)        ║
║  Last Run: 2025-10-16 08:00:00                              ║
║  Status: All certificates valid                              ║
║                                                               ║
║  Backup:                 ✓ Scheduled (Weekly Sunday 3:00 AM) ║
║  Last Run: 2025-10-13 03:00:00                              ║
║  Status: Success (2.3 MB)                                    ║
║                                                               ║
╠══════════════════════════════════════════════════════════════╣
║              Security Headers                                ║
╠══════════════════════════════════════════════════════════════╣
║                                                               ║
║  ✓ Strict-Transport-Security                                ║
║  ✓ X-Frame-Options                                          ║
║  ✓ X-Content-Type-Options                                   ║
║  ✓ X-XSS-Protection                                         ║
║  ✓ Referrer-Policy                                          ║
║  ✓ Content-Security-Policy                                  ║
║  ✓ Permissions-Policy                                       ║
║                                                               ║
╚══════════════════════════════════════════════════════════════╝
```

## 🚀 Quick Command Reference

| Task | Command |
|------|---------|
| **Setup** | `./setup-all.sh` |
| **Test** | `./cert-test.sh` |
| **Deploy** | `./deploy-website.sh` |
| **View Certs** | `sudo certbot certificates` |
| **Test Renewal** | `sudo certbot renew --dry-run` |
| **Force Renewal** | `sudo certbot renew --force-renewal` |
| **View Logs** | `sudo tail -f /var/log/cert-*.log` |
| **Apache Status** | `sudo systemctl status apache2` |
| **Apache Restart** | `sudo systemctl restart apache2` |
| **Apache Config Test** | `sudo apache2ctl configtest` |
| **View Cron Jobs** | `sudo crontab -l` |
| **Manual Backup** | `sudo /usr/local/bin/cert-backup.sh` |
| **Manual Monitor** | `sudo /usr/local/bin/cert-monitor.sh` |

---

**This workflow ensures your SSL/TLS certificates are always valid, secure, and automatically maintained!** 🔒✨
