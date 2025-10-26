# DNS Configuration Guide for timeherenow.com

Before running the SSL certificate setup, you **must** configure your DNS records to point to your server.

## 📋 Required DNS Records

Configure the following A records in your DNS provider's control panel:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | timeherenow.com | `YOUR_SERVER_IP` | 3600 |
| A | www.timeherenow.com | `YOUR_SERVER_IP` | 3600 |

Replace `YOUR_SERVER_IP` with your actual server's IP address.

## 🔍 How to Find Your Server IP

### If you're on the server:
```bash
# Public IP address
curl -4 ifconfig.me
# or
curl -4 icanhazip.com
# or
dig +short myip.opendns.com @resolver1.opendns.com
```

### If you're using a cloud provider:
- **DigitalOcean**: Check your Droplet's dashboard
- **AWS**: Check EC2 instance details
- **Google Cloud**: Check VM instance details
- **Azure**: Check Virtual Machine details

## 🌐 Common DNS Providers

### Namecheap
1. Log in to Namecheap
2. Go to Domain List → Manage
3. Advanced DNS tab
4. Add/Edit A Records:
   - Host: `@` → Value: `YOUR_SERVER_IP`
   - Host: `www` → Value: `YOUR_SERVER_IP`

### GoDaddy
1. Log in to GoDaddy
2. My Products → DNS
3. Add/Edit A Records:
   - Name: `@` → Value: `YOUR_SERVER_IP`
   - Name: `www` → Value: `YOUR_SERVER_IP`

### Cloudflare
1. Log in to Cloudflare
2. Select your domain
3. DNS tab → Add record
4. Add A Records:
   - Name: `timeherenow.com` → IPv4: `YOUR_SERVER_IP` → Proxy: Off (Orange cloud)
   - Name: `www` → IPv4: `YOUR_SERVER_IP` → Proxy: Off (Orange cloud)

**Note:** For initial SSL setup, disable Cloudflare proxy (gray cloud). You can enable it after certificates are obtained.

### Google Domains
1. Log in to Google Domains
2. My domains → Manage → DNS
3. Custom resource records:
   - Name: `@` → Type: A → Data: `YOUR_SERVER_IP`
   - Name: `www` → Type: A → Data: `YOUR_SERVER_IP`

### Route 53 (AWS)
1. Log in to AWS Console
2. Route 53 → Hosted Zones
3. Select your domain
4. Create Record:
   - Record name: (leave empty for root)
   - Record type: A
   - Value: `YOUR_SERVER_IP`
5. Create another record:
   - Record name: `www`
   - Record type: A
   - Value: `YOUR_SERVER_IP`

## ✅ Verify DNS Configuration

After configuring DNS, wait for propagation (usually 5-30 minutes, but can take up to 48 hours).

### Check DNS propagation:

```bash
# Check root domain
dig timeherenow.com +short

# Check www subdomain
dig www.timeherenow.com +short

# Check from multiple locations
# Visit: https://dnschecker.org/#A/timeherenow.com
```

Both commands should return your server's IP address.

### Alternative verification:

```bash
# Using nslookup
nslookup timeherenow.com
nslookup www.timeherenow.com

# Using host
host timeherenow.com
host www.timeherenow.com
```

## ⏱️ DNS Propagation Time

- **Typical time**: 5-30 minutes
- **Maximum time**: 48 hours
- **Factors affecting speed**:
  - TTL (Time To Live) settings
  - DNS provider
  - Your ISP's DNS cache

## 🚨 Common Issues

### DNS not resolving
- **Wait longer**: DNS propagation can take time
- **Clear DNS cache**: 
  ```bash
  # Linux
  sudo systemd-resolve --flush-caches
  
  # macOS
  sudo dscacheutil -flushcache
  
  # Windows
  ipconfig /flushdns
  ```
- **Try different DNS server**: Use Google DNS (8.8.8.8) or Cloudflare DNS (1.1.1.1)

### Wrong IP returned
- **Check DNS records**: Verify in your DNS provider's dashboard
- **Wait for propagation**: Old records may still be cached
- **Check TTL**: Lower TTL for faster updates (e.g., 300 seconds)

### Certificate validation fails
- **Ensure DNS points to correct server**: Let's Encrypt validates domain ownership via DNS
- **Check firewall**: Ensure port 80 is accessible from the internet
- **Disable proxy**: If using Cloudflare, disable proxy (gray cloud) during initial setup

## 📝 Pre-Setup Checklist

Before running the SSL setup scripts, verify:

- [ ] DNS A record for `timeherenow.com` points to your server IP
- [ ] DNS A record for `www.timeherenow.com` points to your server IP
- [ ] DNS has propagated (use `dig` or online tools)
- [ ] Port 80 is open and accessible from the internet
- [ ] Port 443 is open and accessible from the internet
- [ ] You have sudo/root access to the server
- [ ] Server is running Ubuntu/Debian Linux

## 🔧 Test Connectivity

Once DNS is configured, test that your server is reachable:

```bash
# Test port 80 (HTTP)
curl -I http://timeherenow.com

# Test from external tool
# Visit: https://www.whatsmydns.net/#A/timeherenow.com
```

## 🎯 Next Steps

Once DNS is properly configured and propagated:

1. Run the setup scripts in the `certs/` directory
2. Start with `./setup-all.sh` for automatic setup
3. Or follow the step-by-step guide in [QUICKSTART.md](QUICKSTART.md)

---

**Important:** Do not proceed with SSL certificate setup until DNS is properly configured and propagated. Let's Encrypt will fail to validate your domain if DNS is not pointing to your server.
