# GitHub Pages Custom Domain Setup for timeherenow.com

## ⚠️ CURRENT ISSUE: NotServedByPagesError

**Error**: "Domain does not resolve to the GitHub Pages server"

**Solution**: See **[GITHUB-PAGES-FIX.md](GITHUB-PAGES-FIX.md)** for detailed fix instructions.

**Quick Fix**: Go to [Repository Settings → Pages](https://github.com/rodit-org/homepage-discernible-io/settings/pages) and configure the custom domain `timeherenow.com` in the "Custom domain" field.

---

## Current DNS Configuration ✅

Your DNS is correctly configured:

```
timeherenow.com      → 185.199.108.153, 185.199.109.153, 185.199.110.153, 185.199.111.153 (GitHub Pages IPs)
www.timeherenow.com  → CNAME to rodit-org.github.io
```

## Setup Steps

### 1. CNAME File ✅
- Created `public/CNAME` with content: `timeherenow.com`
- This file tells GitHub Pages which custom domain to use
- **Status**: Committed and pushed

### 2. Deploy the CNAME File ✅
```bash
git add public/CNAME .github/workflows/deploy.yml
git commit -m "feat: add CNAME for custom domain timeherenow.com"
git push origin main
```
**Status**: Completed

### 3. Configure Custom Domain in GitHub Settings ⚠️ **ACTION REQUIRED**
This is the missing step causing the NotServedByPagesError:

1. Go to: https://github.com/rodit-org/homepage-discernible-io/settings/pages
2. Under "Build and deployment" → "Source": Verify it's set to **"GitHub Actions"**
3. Under "Custom domain":
   - Enter: `timeherenow.com`
   - Click **Save**
4. Wait for DNS check to complete (1-5 minutes)
5. Once verified, wait for HTTPS certificate (5-15 minutes)
6. Enable "Enforce HTTPS"

## HTTPS Certificate Provisioning

GitHub Pages automatically provisions a Let's Encrypt certificate for your custom domain. This process:
- Takes 5-10 minutes after the CNAME file is deployed
- Requires valid DNS records pointing to GitHub Pages
- Will show "Certificate provisioning in progress" during setup

## Troubleshooting

### Issue: "Certificate not yet created"
**Solution:** Wait 10-15 minutes after deploying the CNAME file. GitHub needs time to provision the certificate.

### Issue: "Domain's DNS record could not be retrieved"
**Solution:** Your DNS is already correct. This should resolve automatically after deployment.

### Issue: "HTTPS not available"
**Causes:**
1. Certificate still provisioning (wait 10-15 minutes)
2. DNS propagation delay (already resolved in your case)
3. CAA records blocking Let's Encrypt (check with: `dig timeherenow.com CAA`)

**Check CAA records:**
```bash
dig timeherenow.com CAA +short
```
If CAA records exist, ensure they allow Let's Encrypt:
```
0 issue "letsencrypt.org"
0 issuewild "letsencrypt.org"
```

### Issue: "SSL certificate error"
This is your current issue. It will be resolved once:
1. The CNAME file is deployed
2. GitHub Pages provisions the certificate (automatic, 5-10 minutes)

## Verification Commands

After deployment and certificate provisioning:

```bash
# Check HTTPS is working
curl -I https://timeherenow.com

# Check certificate details
openssl s_client -connect timeherenow.com:443 -servername timeherenow.com < /dev/null 2>/dev/null | openssl x509 -noout -text

# Check DNS
dig timeherenow.com +short
dig www.timeherenow.com +short
```

## Expected Timeline

1. **Now**: DNS is correctly configured ✅
2. **After commit/push**: CNAME file deployed (~2-3 minutes)
3. **5-10 minutes later**: HTTPS certificate provisioned
4. **Result**: https://timeherenow.com works with valid SSL

## Monitoring Deployment

Watch the GitHub Actions workflow:
https://github.com/rodit-org/homepage-discernible-io/actions

Once the workflow completes successfully, wait 5-10 minutes for certificate provisioning.

## Alternative: Apex Domain with www Redirect

If you prefer `www.timeherenow.com` as primary:
1. Change `CNAME` content to: `www.timeherenow.com`
2. Update DNS A records to point to GitHub Pages IPs (already done)
3. GitHub will automatically redirect apex → www

Current setup uses apex domain (`timeherenow.com`) as primary, which is recommended.

## References

- [GitHub Pages Custom Domain Docs](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)
- [Troubleshooting Custom Domains](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/troubleshooting-custom-domains-and-github-pages)
- [GitHub Pages IP Addresses](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site#configuring-an-apex-domain)
