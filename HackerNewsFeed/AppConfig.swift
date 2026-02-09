import Foundation

enum AppConfig {
    static let githubOwner = "zlatanpham"
    static let githubRepo = "HackerNewsFeed"

    static var latestReleaseURL: URL {
        URL(string: "https://api.github.com/repos/\(githubOwner)/\(githubRepo)/releases/latest")!
    }
}
