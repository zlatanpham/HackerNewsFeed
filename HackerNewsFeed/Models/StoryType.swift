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

    var algoliaTag: String {
        switch self {
        case .top: return "front_page"
        case .new, .best: return "story"
        }
    }

    var useDateSorting: Bool {
        self == .new
    }
}
