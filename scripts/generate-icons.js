#!/usr/bin/env node
const { createCanvas } = require('canvas');
const path = require('path');
const fs = require('fs');

const ROOT_DIR = path.join(__dirname, '..');
const ICON_DIR = path.join(
  ROOT_DIR,
  'HackerNewsFeed',
  'Assets.xcassets',
  'AppIcon.appiconset'
);

// Y Combinator brand colors
const YC_ORANGE = '#FF6600';
const WHITE = '#FFFFFF';

// macOS app icon sizes (size, scale, filename)
const ICON_SIZES = [
  { size: 16, scale: 1, filename: 'icon_16x16.png' },
  { size: 16, scale: 2, filename: 'icon_16x16@2x.png' },
  { size: 32, scale: 1, filename: 'icon_32x32.png' },
  { size: 32, scale: 2, filename: 'icon_32x32@2x.png' },
  { size: 128, scale: 1, filename: 'icon_128x128.png' },
  { size: 128, scale: 2, filename: 'icon_128x128@2x.png' },
  { size: 256, scale: 1, filename: 'icon_256x256.png' },
  { size: 256, scale: 2, filename: 'icon_256x256@2x.png' },
  { size: 512, scale: 1, filename: 'icon_512x512.png' },
  { size: 512, scale: 2, filename: 'icon_512x512@2x.png' },
];

function log(message) {
  console.log(`🎨 ${message}`);
}

function drawIcon(size) {
  const canvas = createCanvas(size, size);
  const ctx = canvas.getContext('2d');

  // Add padding (Apple HIG recommends ~10% on each side for macOS Big Sur+ icons)
  const padding = size * 0.1;
  const contentSize = size - padding * 2;

  // Calculate corner radius based on content size (macOS Big Sur+ style)
  // Apple uses approximately 22.37% of the icon size for corner radius
  const cornerRadius = contentSize * 0.2237;

  // Draw rounded rectangle background with padding
  ctx.fillStyle = YC_ORANGE;
  ctx.beginPath();
  ctx.roundRect(padding, padding, contentSize, contentSize, cornerRadius);
  ctx.fill();

  // Draw "Y" letter
  ctx.fillStyle = WHITE;

  // Font size proportional to content size (approximately 65% of content size)
  const fontSize = Math.round(contentSize * 0.65);
  ctx.font = `bold ${fontSize}px -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif`;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';

  // Position the Y centered within the content area, slightly below center for visual balance
  const centerX = padding + contentSize / 2;
  const centerY = padding + contentSize / 2;
  const yOffset = contentSize * 0.02;
  ctx.fillText('Y', centerX, centerY + yOffset);

  return canvas;
}

function generateIcons() {
  log('Generating Y Combinator style app icons...\n');

  // Ensure icon directory exists
  if (!fs.existsSync(ICON_DIR)) {
    fs.mkdirSync(ICON_DIR, { recursive: true });
  }

  for (const { size, scale, filename } of ICON_SIZES) {
    const actualSize = size * scale;
    const canvas = drawIcon(actualSize);
    const buffer = canvas.toBuffer('image/png');
    const outputPath = path.join(ICON_DIR, filename);

    fs.writeFileSync(outputPath, buffer);
    log(`Generated ${filename} (${actualSize}x${actualSize}px)`);
  }

  console.log('');
  log('All icons generated successfully!\n');
}

function updateContentsJson() {
  log('Updating Contents.json...');

  const contents = {
    images: ICON_SIZES.map(({ size, scale, filename }) => ({
      filename,
      idiom: 'mac',
      scale: `${scale}x`,
      size: `${size}x${size}`,
    })),
    info: {
      author: 'xcode',
      version: 1,
    },
  };

  const contentsPath = path.join(ICON_DIR, 'Contents.json');
  fs.writeFileSync(contentsPath, JSON.stringify(contents, null, 2) + '\n');
  log('Contents.json updated!\n');
}

function main() {
  console.log('\n📦 HackerNewsFeed Icon Generator\n');
  console.log('='.repeat(50) + '\n');

  try {
    generateIcons();
    updateContentsJson();

    console.log('='.repeat(50));
    console.log('\n✅ Success! Icons generated at:');
    console.log(`   ${ICON_DIR}\n`);
  } catch (error) {
    console.error(`\n❌ Error: ${error.message}\n`);
    process.exit(1);
  }
}

main();
