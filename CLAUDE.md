# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/claude-code) when working with code in this repository.

## Project Overview

HackerNewsFeed is a macOS menu bar application for browsing Hacker News, built with SwiftUI. It runs as a menu bar-only app (no Dock icon) and displays stories in a popover panel.

## Build Commands

```bash
make build    # Build Debug configuration
make test     # Run tests
make clean    # Clean build artifacts and DerivedData
make archive  # Build Release archive
make open     # Open project in Xcode
```

Or use Xcode directly: `open HackerNewsFeed.xcodeproj`

## Architecture

**MVVM Pattern:**
- `Models/` - Data structures (Story, StoryType, TimeFilter)
- `Views/` - SwiftUI views
- `ViewModels/` - StoriesViewModel handles state and business logic
- `Services/` - HackerNewsService (actor) handles API calls

**Key Design Decisions:**
- `HackerNewsService` is an `actor` for thread-safe concurrent API access
- Stories are fetched concurrently using `TaskGroup`
- Results are cached in-memory for 5 minutes per story type
- Uses official HN Firebase API: `https://hacker-news.firebaseio.com/v0/`

## Key Files

- `AppDelegate.swift` - Sets up NSStatusItem and NSPopover for menu bar
- `StoriesViewModel.swift` - Main state management, caching logic
- `HackerNewsService.swift` - API client with error handling
- `Info.plist` - Contains `LSUIElement = true` for menu bar-only mode

## API Endpoints Used

- `topstories.json` - Top stories
- `beststories.json` - Best stories
- `newstories.json` - New stories
- `item/{id}.json` - Individual story details

## Common Tasks

**Adding a new story type:**
1. Add case to `StoryType` enum in `Models/StoryType.swift`
2. Implement `title`, `iconName`, and `endpoint` properties

**Modifying the story row UI:**
- Edit `Views/StoryRowView.swift`

**Changing cache duration:**
- Modify `cacheValidityDuration` in `StoriesViewModel.swift` (currently 300 seconds)

**Adding new filters:**
- Add case to `TimeFilter` enum in `Models/TimeFilter.swift`
- Implement `cutoffDate` logic
