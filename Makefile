SCHEME = HackerNewsFeed
PROJECT = HackerNewsFeed.xcodeproj

.PHONY: build test clean archive open dmg help

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Debug build

test:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) test

clean:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean
	rm -rf DerivedData build dist

archive:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Release archive

open:
	open $(PROJECT)

dmg:
	npm run build:dmg

help:
	@echo "make build   - Build the app"
	@echo "make test    - Run tests"
	@echo "make clean   - Clean build artifacts"
	@echo "make archive - Create release archive"
	@echo "make open    - Open in Xcode"
	@echo "make dmg     - Create DMG installer"
