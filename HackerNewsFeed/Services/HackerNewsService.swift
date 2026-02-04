import Foundation

actor HackerNewsService {
    static let shared = HackerNewsService()

    private let baseURL = "https://hacker-news.firebaseio.com/v0/"
    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }

    func fetchStoryIDs(for storyType: StoryType) async throws -> [Int] {
        let urlString = baseURL + storyType.endpoint
        guard let url = URL(string: urlString) else {
            throw HackerNewsError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw HackerNewsError.invalidResponse
        }

        let ids = try decoder.decode([Int].self, from: data)
        return ids
    }

    func fetchStory(id: Int) async throws -> Story {
        let urlString = baseURL + "item/\(id).json"
        guard let url = URL(string: urlString) else {
            throw HackerNewsError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw HackerNewsError.invalidResponse
        }

        let story = try decoder.decode(Story.self, from: data)
        return story
    }

    func fetchStories(ids: [Int], limit: Int = 100) async throws -> [Story] {
        let limitedIDs = Array(ids.prefix(limit))

        return try await withThrowingTaskGroup(of: Story?.self, returning: [Story].self) { group in
            for id in limitedIDs {
                group.addTask {
                    do {
                        return try await self.fetchStory(id: id)
                    } catch {
                        return nil
                    }
                }
            }

            var stories: [Story] = []
            for try await story in group {
                if let story = story {
                    stories.append(story)
                }
            }

            // Sort by the original order of IDs
            let idToIndex = Dictionary(uniqueKeysWithValues: limitedIDs.enumerated().map { ($1, $0) })
            stories.sort { story1, story2 in
                let index1 = idToIndex[story1.id] ?? Int.max
                let index2 = idToIndex[story2.id] ?? Int.max
                return index1 < index2
            }

            return stories
        }
    }
}

enum HackerNewsError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
