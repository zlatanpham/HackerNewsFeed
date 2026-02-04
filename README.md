# HackerNewsFeed

A macOS menu bar application for browsing Hacker News.

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later

## Features

- Menu bar icon using SF Symbol `newspaper.fill`
- Popover panel that opens when clicking the icon
- Browse Top, Best, and New stories from Hacker News
- Filter stories by time period (24h, Week, Month, All)
- Open stories in browser or view HN comments
- Copy story links to clipboard
- 5-minute caching to reduce API calls
- No Dock icon (menu bar-only app)
- Works in both light and dark mode

## Building

### Using Xcode

1. Open `HackerNewsFeed.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Build and run (Cmd+R)

### Using Make

```bash
make build    # Build the app (Debug)
make test     # Run tests
make clean    # Clean build artifacts
make archive  # Create release archive
make open     # Open project in Xcode
```

## Project Structure

```
HackerNewsFeed/
├── HackerNewsFeedApp.swift       # App entry point with @main
├── AppDelegate.swift             # Menu bar status item and popover setup
├── ContentView.swift             # Main popover content view
├── Models/
│   ├── Story.swift               # HN story data model
│   ├── StoryType.swift           # Story feed types (top/best/new)
│   └── TimeFilter.swift          # Time-based filtering options
├── Views/
│   ├── StoryListView.swift       # Story list container
│   ├── StoryRowView.swift        # Individual story row
│   ├── LoadingView.swift         # Loading indicator
│   └── TimeFilterPicker.swift    # Time filter UI
├── ViewModels/
│   └── StoriesViewModel.swift    # Business logic and state management
├── Services/
│   └── HackerNewsService.swift   # HN API client (actor-based)
├── Extensions/
│   └── Date+Extensions.swift     # Date formatting helpers
├── Assets.xcassets/              # App icons and colors
├── Info.plist                    # App configuration
└── HackerNewsFeed.entitlements
```

## Architecture

- **MVVM pattern** with SwiftUI
- **Actor-based service** for thread-safe API calls
- **Async/await** for concurrent story fetching
- **In-memory caching** with 5-minute validity

## Configuration

The app is configured as a menu bar-only application via `LSUIElement = true` in Info.plist, which hides it from the Dock.
