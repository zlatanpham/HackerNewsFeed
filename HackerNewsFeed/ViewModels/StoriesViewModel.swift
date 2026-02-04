import Foundation
import SwiftUI

@MainActor
class StoriesViewModel: ObservableObject {
    @Published var selectedStoryType: StoryType = .top
    @Published var selectedTimeFilter: TimeFilter = .all
    @Published var stories: [Story] = []
    @Published var isLoading = false
    @Published var error: String?

    private var cache: [CacheKey: CachedStories] = [:]
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes

    private struct CacheKey: Hashable {
        let storyType: StoryType
        let timeFilter: TimeFilter
    }

    private struct CachedStories {
        let stories: [Story]
        let timestamp: Date

        var isValid: Bool {
            Date().timeIntervalSince(timestamp) < 300
        }
    }

    func loadStories() async {
        let cacheKey = CacheKey(storyType: selectedStoryType, timeFilter: selectedTimeFilter)

        // Check cache first
        if let cached = cache[cacheKey], cached.isValid {
            stories = cached.stories
            return
        }

        isLoading = true
        error = nil

        do {
            let fetchedStories = try await HackerNewsService.shared.fetchStories(
                for: selectedStoryType,
                timeFilter: selectedTimeFilter,
                limit: 100
            )

            stories = fetchedStories
            cache[cacheKey] = CachedStories(stories: fetchedStories, timestamp: Date())
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        // Invalidate cache for current type+filter combination
        let cacheKey = CacheKey(storyType: selectedStoryType, timeFilter: selectedTimeFilter)
        cache[cacheKey] = nil
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

    func openAuthor(_ story: Story) {
        guard let url = story.authorProfileURL else { return }
        NSWorkspace.shared.open(url)
    }

    func copyLink(_ story: Story) {
        let url = story.storyURL ?? story.commentsURL
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url.absoluteString, forType: .string)
    }
}
