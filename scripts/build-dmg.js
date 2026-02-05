#!/usr/bin/env node
const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const appdmg = require('appdmg');

const ROOT_DIR = path.join(__dirname, '..');
const BUILD_DIR = path.join(ROOT_DIR, 'build');
const DIST_DIR = path.join(ROOT_DIR, 'dist');
const APP_NAME = 'HackerNewsFeed';
const SCHEME = 'HackerNewsFeed';
const PROJECT = 'HackerNewsFeed.xcodeproj';

// Read version from package.json
const packageJson = JSON.parse(
  fs.readFileSync(path.join(ROOT_DIR, 'package.json'), 'utf8')
);
const VERSION = packageJson.version;

const APP_PATH = path.join(
  BUILD_DIR,
  'Release',
  `${APP_NAME}.app`
);
const DMG_PATH = path.join(DIST_DIR, `${APP_NAME}-${VERSION}.dmg`);

function log(message) {
  console.log(`\n🔨 ${message}`);
}

function cleanPreviousBuilds() {
  log('Cleaning previous builds...');

  // Clean build directory
  if (fs.existsSync(BUILD_DIR)) {
    fs.rmSync(BUILD_DIR, { recursive: true });
  }

  // Clean dist directory
  if (fs.existsSync(DIST_DIR)) {
    fs.rmSync(DIST_DIR, { recursive: true });
  }

  // Clean Xcode build
  execSync(`xcodebuild -project ${PROJECT} -scheme ${SCHEME} clean`, {
    cwd: ROOT_DIR,
    stdio: 'inherit',
  });
}

function buildRelease() {
  log('Building Release configuration...');

  execSync(
    `xcodebuild -project ${PROJECT} -scheme ${SCHEME} -configuration Release ` +
      `-derivedDataPath ${BUILD_DIR} ` +
      `CONFIGURATION_BUILD_DIR=${path.join(BUILD_DIR, 'Release')} ` +
      'build',
    {
      cwd: ROOT_DIR,
      stdio: 'inherit',
    }
  );

  // Verify .app was created
  if (!fs.existsSync(APP_PATH)) {
    throw new Error(`Build failed: ${APP_PATH} not found`);
  }

  log(`Build successful: ${APP_PATH}`);
}

function createDmg() {
  return new Promise((resolve, reject) => {
    log('Creating DMG...');

    // Ensure dist directory exists
    fs.mkdirSync(DIST_DIR, { recursive: true });

    // Remove existing DMG if present
    if (fs.existsSync(DMG_PATH)) {
      fs.unlinkSync(DMG_PATH);
    }

    const dmgConfig = {
      target: DMG_PATH,
      basepath: ROOT_DIR,
      specification: {
        title: APP_NAME,
        contents: [
          { x: 192, y: 240, type: 'file', path: APP_PATH },
          { x: 448, y: 240, type: 'link', path: '/Applications' },
        ],
        window: {
          size: {
            width: 640,
            height: 480,
          },
        },
        format: 'UDZO',
      },
    };

    const dmg = appdmg(dmgConfig);

    dmg.on('progress', (info) => {
      if (info.type === 'step-begin') {
        process.stdout.write(`   ${info.title}...`);
      } else if (info.type === 'step-end') {
        process.stdout.write(' done\n');
      }
    });

    dmg.on('finish', () => {
      log(`DMG created successfully: ${DMG_PATH}`);
      resolve();
    });

    dmg.on('error', (err) => {
      reject(new Error(`DMG creation failed: ${err.message}`));
    });
  });
}

async function main() {
  console.log(`\n📦 Building ${APP_NAME} v${VERSION} DMG\n`);
  console.log('='.repeat(50));

  try {
    cleanPreviousBuilds();
    buildRelease();
    await createDmg();

    console.log('\n' + '='.repeat(50));
    console.log(`\n✅ Success! DMG created at:\n   ${DMG_PATH}\n`);
  } catch (error) {
    console.error(`\n❌ Error: ${error.message}\n`);
    process.exit(1);
  }
}

main();
