# Fix: "Domain does not resolve to the GitHub Pages server" Error

## Error Details
```
discernible.io is improperly configured
Domain does not resolve to the GitHub Pages server. 
For more information, see documentation (NotServedByPagesError).
```

## Root Cause

This error occurs when GitHub Pages is not properly enabled or configured in the repository settings, even though:
- ✅ DNS is correctly pointing to GitHub Pages IPs
- ✅ CNAME file exists in the repository
- ✅ GitHub Actions workflow is deploying

## Solution Steps

### Step 1: Enable GitHub Pages in Repository Settings

1. Go to: **https://github.com/rodit-org/homepage-discernible-io/settings/pages**

2. Under **"Build and deployment"**, verify:
   - **Source**: Should be set to **"GitHub Actions"** (not "Deploy from a branch")
   
3. Under **"Custom domain"**:
   - The field should show: `discernible.io`
   - If it's empty or shows an error, you need to configure it

### Step 2: Configure Custom Domain

If the custom domain field is empty or shows an error:

1. **Remove any existing domain** (if present and showing error)
2. **Wait 1 minute** for GitHub to clear the cache
3. **Add the domain again**:
   - Enter: `discernible.io`
   - Click **Save**
4. **Wait for DNS check** (this can take 1-5 minutes)
5. GitHub will verify the DNS records and show one of:
   - ✅ "DNS check successful"
   - ⚠️ "DNS check in progress" (wait)
   - ❌ "DNS check failed" (see troubleshooting below)

### Step 3: Verify GitHub Actions Deployment

1. Go to: **https://github.com/rodit-org/homepage-discernible-io/actions**
2. Check the latest "Deploy to GitHub Pages" workflow
3. Ensure it completed successfully
4. If it failed, check the logs for errors

### Step 4: Wait for Propagation

After configuring the custom domain:
- **DNS verification**: 1-5 minutes
- **HTTPS certificate**: 5-15 minutes
- **Full propagation**: Up to 1 hour

## Why This Happens

The **NotServedByPagesError** specifically means:
1. GitHub Pages doesn't recognize your domain in its routing table
2. Even though DNS points to GitHub's IPs, GitHub doesn't know which repository to serve
3. The custom domain must be configured in repository settings to create this mapping

Think of it like this:
- **DNS** = Tells browsers "go to GitHub's servers"
- **Custom domain setting** = Tells GitHub "serve this repository for this domain"
- Both are required!

## Verification Commands

After completing the steps above:

```bash
# 1. Verify DNS is correct (should return GitHub Pages IPs)
dig discernible.io +short
# Expected: 185.199.108.153, 185.199.109.153, 185.199.110.153, 185.199.111.153

# 2. Check if GitHub is serving the site
curl -I http://discernible.io
# Should return: HTTP/1.1 200 OK (not 404)

# 3. Check HTTPS (may take 10-15 minutes after domain configuration)
curl -I https://discernible.io
# Should return: HTTP/2 200 (with valid SSL certificate)

# 4. Verify CNAME file is deployed
curl -s https://rodit-org.github.io/homepage-discernible-io/CNAME
# Should return: discernible.io
```

## Common Issues & Solutions

### Issue 1: "DNS check failed"
**Cause**: DNS records not propagated or incorrect

**Solution**:
```bash
# Verify your DNS records
dig discernible.io +short
# Should show: 185.199.108.153, 185.199.109.153, 185.199.110.153, 185.199.111.153

dig www.discernible.io +short
# Should show: rodit-org.github.io. followed by the IPs
```

If DNS is wrong, update your DNS provider settings:
- **A records** for `discernible.io` → `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
- **CNAME record** for `www.discernible.io` → `rodit-org.github.io`

### Issue 2: "Domain is already taken"
**Cause**: Another GitHub user/org has claimed this domain

**Solution**: Verify domain ownership (see next section)

### Issue 3: GitHub Actions workflow failing
**Cause**: Permissions or configuration issue

**Solution**:
1. Check workflow file has correct permissions (already correct in your case)
2. Ensure GitHub Pages is enabled in repository settings
3. Check Actions logs for specific errors

### Issue 4: 404 error when visiting site
**Cause**: CNAME file not in the deployed artifact

**Solution**: Already fixed in your workflow - CNAME is copied to `gh-pages/` directory

## Domain Verification (Recommended)

To prevent domain takeovers and ensure only your organization can use this domain:

### For Organization (rodit-org):

1. Go to: **https://github.com/organizations/rodit-org/settings/pages**
2. Click **"Add a domain"**
3. Enter: `discernible.io`
4. Add the TXT record shown (you already have this):
   ```
   _github-pages-challenge-rodit-org.discernible.io → "297483344bf1104ad15b6d2d58e982"
   ```
5. Click **"Verify"**

This is **optional but highly recommended** for security.

## Expected Timeline

1. **Now**: Configure custom domain in repository settings
2. **1-5 minutes**: DNS check completes
3. **5-15 minutes**: HTTPS certificate provisioned
4. **Result**: https://discernible.io works perfectly

## Quick Checklist

- [ ] GitHub Pages enabled in repository settings (Source: GitHub Actions)
- [ ] Custom domain configured: `discernible.io`
- [ ] DNS check shows "successful" (green checkmark)
- [ ] Latest GitHub Actions workflow completed successfully
- [ ] CNAME file exists in deployed artifact
- [ ] Wait 10-15 minutes for HTTPS certificate
- [ ] (Optional) Domain verified at organization level

## Direct Links

- **Repository Pages Settings**: https://github.com/rodit-org/homepage-discernible-io/settings/pages
- **GitHub Actions**: https://github.com/rodit-org/homepage-discernible-io/actions
- **Organization Pages Settings**: https://github.com/organizations/rodit-org/settings/pages
- **GitHub Pages Documentation**: https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site

## Next Steps

1. **Immediately**: Go to repository settings and configure the custom domain
2. **Wait 5 minutes**: Let GitHub verify DNS and update routing
3. **Test**: Visit http://discernible.io (should work)
4. **Wait 15 minutes**: HTTPS certificate will be provisioned
5. **Enable HTTPS**: Check "Enforce HTTPS" in repository settings
6. **Done**: Visit https://discernible.io

---

**Note**: The error message is misleading - it says "domain does not resolve" but actually means "GitHub doesn't know to serve your repository for this domain". The fix is in GitHub settings, not DNS.
