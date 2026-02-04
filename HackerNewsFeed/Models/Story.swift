import Foundation

struct Story: Codable, Identifiable, Equatable {
    let id: Int
    let title: String?
    let url: String?
    let score: Int?
    let by: String?
    let time: Int?
    let descendants: Int?

    var displayTitle: String {
        title ?? "Untitled"
    }

    var displayScore: Int {
        score ?? 0
    }

    var displayAuthor: String {
        by ?? "unknown"
    }

    var commentCount: Int {
        descendants ?? 0
    }

    var storyURL: URL? {
        guard let url = url else { return nil }
        return URL(string: url)
    }

    var commentsURL: URL {
        URL(string: "https://news.ycombinator.com/item?id=\(id)")!
    }

    var domain: String? {
        guard let url = storyURL, let host = url.host else { return nil }
        return host.replacingOccurrences(of: "www.", with: "")
    }

    var timeDate: Date? {
        guard let time = time else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(time))
    }
}
