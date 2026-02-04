import Foundation

actor HackerNewsService {
    static let shared = HackerNewsService()

    private let baseURL = "https://hn.algolia.com/api/v1/"
    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }

    func fetchStories(for storyType: StoryType, timeFilter: TimeFilter, limit: Int = 100) async throws -> [Story] {
        let endpoint = storyType.useDateSorting ? "search_by_date" : "search"

        var components = URLComponents(string: baseURL + endpoint)!
        var queryItems = [
            URLQueryItem(name: "tags", value: storyType.algoliaTag),
            URLQueryItem(name: "hitsPerPage", value: String(limit))
        ]

        if let numericFilter = timeFilter.algoliaNumericFilter {
            queryItems.append(URLQueryItem(name: "numericFilters", value: numericFilter))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw HackerNewsError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw HackerNewsError.invalidResponse
        }

        let algoliaResponse = try decoder.decode(AlgoliaSearchResponse.self, from: data)
        var stories = algoliaResponse.hits.map { Story(from: $0) }

        // For "best" stories, sort by points (score) descending
        if storyType == .best {
            stories.sort { ($0.score ?? 0) > ($1.score ?? 0) }
        }

        return stories
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
