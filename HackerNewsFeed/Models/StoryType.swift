import Foundation

enum StoryType: String, CaseIterable, Identifiable {
    case new
    case best
    case top

    var id: String { rawValue }

    var title: String {
        switch self {
        case .new: return "New"
        case .best: return "Best"
        case .top: return "Top"
        }
    }

    var iconName: String {
        switch self {
        case .new: return "sparkles"
        case .best: return "star.fill"
        case .top: return "flame.fill"
        }
    }

    var endpoint: String {
        switch self {
        case .new: return "newstories.json"
        case .best: return "beststories.json"
        case .top: return "topstories.json"
        }
    }
}
