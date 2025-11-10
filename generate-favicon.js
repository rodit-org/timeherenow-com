const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

// Create a modern favicon with a stylized "T" design for TimeHereNow
async function generateFavicon() {
  const sizes = [16, 32, 48, 64, 128, 256];
  const publicDir = path.join(__dirname, 'public');
  
  // Create SVG for the favicon - a modern "T" design with TimeHereNow theme
  const createSVG = (size) => `
    <svg width="${size}" height="${size}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" style="stop-color:#4F46E5;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#7C3AED;stop-opacity:1" />
        </linearGradient>
      </defs>
      <!-- Background circle -->
      <circle cx="${size/2}" cy="${size/2}" r="${size/2}" fill="url(#grad)"/>
      <!-- Stylized "T" shape -->
      <path d="M ${size*0.25} ${size*0.25} 
               L ${size*0.75} ${size*0.25} 
               L ${size*0.75} ${size*0.35} 
               L ${size*0.55} ${size*0.35}
               L ${size*0.55} ${size*0.75}
               L ${size*0.45} ${size*0.75}
               L ${size*0.45} ${size*0.35}
               L ${size*0.25} ${size*0.35}
               Z" 
            fill="white"/>
    </svg>
  `;

  // Generate favicon.ico (multi-size ICO file)
  console.log('Generating favicon files...');
  
  // Generate individual PNG files for different sizes
  for (const size of sizes) {
    const svg = Buffer.from(createSVG(size));
    await sharp(svg)
      .resize(size, size)
      .png()
      .toFile(path.join(publicDir, `favicon-${size}x${size}.png`));
    console.log(`✓ Generated favicon-${size}x${size}.png`);
  }

  // Generate the main favicon.ico (keep as PNG for now, browsers support it)
  // Note: For true .ico format, we'd need a different library
  const svg32 = Buffer.from(createSVG(32));
  await sharp(svg32)
    .resize(32, 32)
    .png()
    .toFile(path.join(publicDir, 'favicon.ico'));
  console.log('✓ Generated favicon.ico');

  // Generate apple-touch-icon (180x180)
  const svg180 = Buffer.from(createSVG(180));
  await sharp(svg180)
    .resize(180, 180)
    .png()
    .toFile(path.join(publicDir, 'apple-touch-icon.png'));
  console.log('✓ Generated apple-touch-icon.png');

  // Generate android-chrome icons
  const svg192 = Buffer.from(createSVG(192));
  await sharp(svg192)
    .resize(192, 192)
    .png()
    .toFile(path.join(publicDir, 'android-chrome-192x192.png'));
  console.log('✓ Generated android-chrome-192x192.png');

  const svg512 = Buffer.from(createSVG(512));
  await sharp(svg512)
    .resize(512, 512)
    .png()
    .toFile(path.join(publicDir, 'android-chrome-512x512.png'));
  console.log('✓ Generated android-chrome-512x512.png');

  // Generate site.webmanifest
  const manifest = {
    name: "TimeHereNow",
    short_name: "TimeHereNow",
    description: "Blockchain-powered time services with RODiT authentication",
    icons: [
      {
        src: "/android-chrome-192x192.png",
        sizes: "192x192",
        type: "image/png"
      },
      {
        src: "/android-chrome-512x512.png",
        sizes: "512x512",
        type: "image/png"
      }
    ],
    theme_color: "#4F46E5",
    background_color: "#ffffff",
    display: "standalone"
  };

  fs.writeFileSync(
    path.join(publicDir, 'site.webmanifest'),
    JSON.stringify(manifest, null, 2)
  );
  console.log('✓ Generated site.webmanifest');

  // Generate browserconfig.xml for Windows tiles
  const browserconfig = `<?xml version="1.0" encoding="utf-8"?>
<browserconfig>
    <msapplication>
        <tile>
            <square150x150logo src="/favicon-256x256.png"/>
            <TileColor>#4F46E5</TileColor>
        </tile>
    </msapplication>
</browserconfig>`;

  fs.writeFileSync(
    path.join(publicDir, 'browserconfig.xml'),
    browserconfig
  );
  console.log('✓ Generated browserconfig.xml');

  // Generate favicon.svg for modern browsers
  const svgContent = createSVG(512);
  fs.writeFileSync(
    path.join(publicDir, 'favicon.svg'),
    svgContent
  );
  console.log('✓ Generated favicon.svg');

  console.log('\n✅ All favicon files generated successfully!');
  console.log('\nNext step: Add the following lines to the <head> section of your HTML:');
  console.log(`
  <link rel="icon" type="image/x-icon" href="/favicon.ico">
  <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
  <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
  <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
  <link rel="icon" type="image/png" sizes="192x192" href="/android-chrome-192x192.png">
  <link rel="icon" type="image/png" sizes="512x512" href="/android-chrome-512x512.png">
  <link rel="manifest" href="/site.webmanifest">
  <meta name="theme-color" content="#4F46E5">
  `);
}

generateFavicon().catch(console.error);
