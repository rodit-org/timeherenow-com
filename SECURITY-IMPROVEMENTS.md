# Security Hardening Applied

## Changes Made (Non-Intrusive)

### 1. ✅ Apache Virtual Host Configuration
**File**: `certs/apache-virtualhost.conf`
- **Changed**: `Options Indexes` → `Options -Indexes +FollowSymLinks`
- **Benefit**: Prevents directory listing attacks
- **Impact**: None (users shouldn't browse directories anyway)

### 2. ✅ Security Headers in .htaccess
**File**: `public/.htaccess`
- **Added**:
  - `X-Frame-Options: SAMEORIGIN` - Prevents clickjacking
  - `X-Content-Type-Options: nosniff` - Prevents MIME sniffing attacks
  - `Referrer-Policy: strict-origin-when-cross-origin` - Controls referrer information
  - `Content-Security-Policy` - Restricts resource loading
- **Benefit**: Protects against XSS, clickjacking, and other client-side attacks
- **Impact**: Minimal (CSP allows inline scripts/styles as needed)

### 3. ✅ File Access Protection
**File**: `public/.htaccess`
- **Added**:
  - Block access to hidden files (`.htaccess`, `.git`, etc.)
  - Block access to backup/config files (`.bak`, `.sql`, `.log`, etc.)
- **Benefit**: Prevents exposure of sensitive files
- **Impact**: None (these files shouldn't be accessed via web anyway)

### 4. ✅ Deploy Script Hardening
**File**: `deploy.sh`
- **Added**:
  - `set -u` - Exit on undefined variables
  - `set -o pipefail` - Catch errors in pipes
  - Source directory validation
- **Benefit**: Prevents deployment errors and potential security issues
- **Impact**: Script will fail fast on errors (safer)

## Already Secure

- ✅ External links use `rel="noopener"` (prevents tab-nabbing)
- ✅ Security headers configuration exists in `certs/security-headers.conf`
- ✅ SSL/TLS setup planned with Let's Encrypt
- ✅ No inline event handlers in HTML
- ✅ No sensitive data in client-side code

## Recommended Next Steps (When Ready)

### High Priority
1. **Enable HTTPS** - Run the SSL setup scripts in `certs/` directory
2. **Add HSTS Header** - After HTTPS is enabled (already in `security-headers.conf`)
3. **Test Security Headers** - Use https://securityheaders.com/

### Medium Priority
4. **Add Rate Limiting** - Consider using `mod_evasive` or `fail2ban`
5. **Enable ModSecurity** - Web application firewall for Apache
6. **Regular Updates** - Keep Apache, OS, and dependencies updated

### Low Priority
7. **Add Subresource Integrity (SRI)** - If using external CDN resources
8. **Implement Logging/Monitoring** - Track suspicious activity
9. **Add robots.txt** - Control crawler access

## Testing Commands

After deploying changes:

```bash
# Test Apache configuration
sudo apache2ctl configtest

# Check security headers (after deployment)
curl -I https://timeherenow.com

# Test SSL configuration (after HTTPS enabled)
./certs/cert-test.sh
```

## Notes

- All changes are backward compatible
- No functionality is broken
- Changes follow Apache and OWASP best practices
- CSP policy allows inline scripts/styles (required for current code)
- Can be tightened further if you refactor inline scripts to external files

## Rollback

If any issues occur, original files are in git history:
```bash
git diff HEAD~1 public/.htaccess
git diff HEAD~1 certs/apache-virtualhost.conf
git diff HEAD~1 deploy.sh
```
