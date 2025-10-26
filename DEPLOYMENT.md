# Deployment Guide

## Overview

This repository supports two deployment targets:
1. **Apache web server** at `/var/www/domains/discernible.io/public_html/` (with `.htaccess` support)
2. **GitHub Pages** at `https://rodit-org.github.io/homepage-discernible-io/` (without `.htaccess`)

## Automatic Deployment

### Setup (Already Configured)
- ✅ Git post-commit hook installed at `.git/hooks/post-commit`
- ✅ Deployment script created at `deploy.sh`
- ✅ Apache configured to serve from `/var/www/domains/discernible.io/public_html/`

### How to Use
Simply commit your changes and they will automatically deploy:

```bash
# Make your changes to files in public/
vim public/index.html

# Commit your changes
git add .
git commit -m "Update homepage content"

# Deployment happens automatically!
```

## Manual Deployment

If you need to deploy without committing:

```bash
./deploy.sh
```

## Troubleshooting

### Check deployment logs
```bash
tail -f deploy.log
```

### Verify files are deployed
```bash
ls -la /var/www/domains/discernible.io/public_html/
```

### Check Apache status
```bash
sudo systemctl status apache2
```

### Reload Apache manually
```bash
sudo systemctl reload apache2
```

### Test with curl (bypass browser cache)
```bash
curl -I https://discernible.io/
```

## Color Scheme

The website uses the brand colors from the discernible.io logo:

- **Primary (Orange)**: `#FF4500`
- **Secondary (Black)**: `#000000`
- **Accent (Light Orange)**: `#FF6B35`
- **White**: `#FFFFFF`

These are defined in `public/styles.css` under the `:root` selector.

## File Structure

```
/home/icarus40/homepage-discernible-io/  (Development)
└── public/
    ├── index.html
    ├── styles.css
    ├── script.js
    └── .htaccess

/var/www/domains/discernible.io/public_html/  (Production)
└── (Same files as above, deployed automatically)
```

## GitHub Pages Deployment

### Automatic Deployment
- Pushes to `main` branch automatically trigger GitHub Pages deployment
- GitHub Actions workflow at `.github/workflows/deploy.yml`
- Deploys only web assets (HTML, CSS, JS, images) - `.htaccess` is excluded
- `.nojekyll` file is automatically added to prevent Jekyll processing

### Custom Domain Configuration
- **Primary domain**: `discernible.io`
- **CNAME file**: `public/CNAME` contains the custom domain
- **DNS**: Already configured to point to GitHub Pages IPs
- **HTTPS**: Automatically provisioned by GitHub (Let's Encrypt)
- **Certificate provisioning time**: 5-10 minutes after first deployment

### Important GitHub Pages Notes
- GitHub Pages does **not** support `.htaccess` files
- Security headers and caching rules from `.htaccess` won't apply on GitHub Pages
- GitHub Pages uses its own server configuration
- HTTPS is automatically enabled for custom domains (after certificate provisioning)

## Important Notes

1. **Always edit files in `/home/icarus40/homepage-discernible-io/public/`**, not in the Apache directory
2. **Commit your changes** to trigger automatic deployment (both Apache and GitHub Pages)
3. **Check deploy.log** for Apache deployment issues
4. The `.htaccess` file only works on Apache, not on GitHub Pages
