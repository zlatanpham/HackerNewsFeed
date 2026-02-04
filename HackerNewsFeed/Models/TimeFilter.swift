import Foundation

enum TimeFilter: String, CaseIterable, Identifiable {
    case day
    case week
    case month
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .day: return "24h"
        case .week: return "Week"
        case .month: return "Month"
        case .all: return "All"
        }
    }

    var cutoffDate: Date? {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .day:
            return calendar.date(byAdding: .day, value: -1, to: now)
        case .week:
            return calendar.date(byAdding: .weekOfYear, value: -1, to: now)
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: now)
        case .all:
            return nil
        }
    }

    func includes(date: Date?) -> Bool {
        guard let date = date else { return true }
        guard let cutoff = cutoffDate else { return true }
        return date >= cutoff
    }

    var algoliaNumericFilter: String? {
        guard let cutoff = cutoffDate else { return nil }
        return "created_at_i>\(Int(cutoff.timeIntervalSince1970))"
    }
}
