.PHONY: build test clean archive open dmg help

# Project settings
PROJECT_NAME = HackerNewsFeed
SCHEME = $(PROJECT_NAME)
PROJECT = $(PROJECT_NAME).xcodeproj
BUILD_DIR = build
ARCHIVE_PATH = $(BUILD_DIR)/$(PROJECT_NAME).xcarchive

# Code signing identity (override with SIGN_IDENTITY env var)
SIGN_IDENTITY ?= HackerNewsFeed Distribution

# Optional: pass VERSION=x.y.z to inject version into the build
ifdef VERSION
VERSION_FLAGS = MARKETING_VERSION=$(VERSION) CURRENT_PROJECT_VERSION=$(VERSION)
endif

# Default target
help:
	@echo "Available targets:"
	@echo "  build   - Build the app (Debug)"
	@echo "  test    - Run tests"
	@echo "  clean   - Clean build artifacts"
	@echo "  archive - Create release archive"
	@echo "  dmg     - Create DMG installer"
	@echo "  open    - Open in Xcode"
	@echo ""
	@echo "Options:"
	@echo "  VERSION=x.y.z  - Set version for archive/dmg targets"

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Debug build

test:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) test

clean:
	rm -rf $(BUILD_DIR)
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean 2>/dev/null || true

archive:
	xcodebuild -project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration Release \
		-archivePath $(ARCHIVE_PATH) \
		CODE_SIGN_IDENTITY="$(SIGN_IDENTITY)" \
		CODE_SIGN_STYLE=Manual \
		$(VERSION_FLAGS) \
		archive

open:
	open $(PROJECT)

dmg: archive
	VERSION=$(VERSION) npm run build:dmg
