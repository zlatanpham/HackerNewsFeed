import Foundation
import SwiftUI

@MainActor
class StoriesViewModel: ObservableObject {
    @Published var selectedStoryType: StoryType = .top
    @Published var selectedTimeFilter: TimeFilter = .all
    @Published var stories: [Story] = []
    @Published var isLoading = false
    @Published var error: String?

    private var cache: [StoryType: CachedStories] = [:]
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes

    private struct CachedStories {
        let stories: [Story]
        let timestamp: Date

        var isValid: Bool {
            Date().timeIntervalSince(timestamp) < 300
        }
    }

    var filteredStories: [Story] {
        stories.filter { story in
            selectedTimeFilter.includes(date: story.timeDate)
        }
    }

    func loadStories() async {
        // Check cache first
        if let cached = cache[selectedStoryType], cached.isValid {
            stories = cached.stories
            return
        }

        isLoading = true
        error = nil

        do {
            let ids = try await HackerNewsService.shared.fetchStoryIDs(for: selectedStoryType)
            let fetchedStories = try await HackerNewsService.shared.fetchStories(ids: ids, limit: 100)

            stories = fetchedStories
            cache[selectedStoryType] = CachedStories(stories: fetchedStories, timestamp: Date())
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        // Invalidate cache for current type
        cache[selectedStoryType] = nil
        await loadStories()
    }

    func openStory(_ story: Story) {
        guard let url = story.storyURL else {
            openComments(story)
            return
        }
        NSWorkspace.shared.open(url)
    }

    func openComments(_ story: Story) {
        NSWorkspace.shared.open(story.commentsURL)
    }

    func copyLink(_ story: Story) {
        let url = story.storyURL ?? story.commentsURL
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url.absoluteString, forType: .string)
    }
}
