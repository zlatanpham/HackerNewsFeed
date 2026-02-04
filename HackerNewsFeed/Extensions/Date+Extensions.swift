import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let now = Date()
        let components = Calendar.current.dateComponents(
            [.year, .month, .weekOfYear, .day, .hour, .minute],
            from: self,
            to: now
        )

        if let years = components.year, years > 0 {
            return years == 1 ? "1y ago" : "\(years)y ago"
        }

        if let months = components.month, months > 0 {
            return months == 1 ? "1mo ago" : "\(months)mo ago"
        }

        if let weeks = components.weekOfYear, weeks > 0 {
            return weeks == 1 ? "1w ago" : "\(weeks)w ago"
        }

        if let days = components.day, days > 0 {
            return days == 1 ? "1d ago" : "\(days)d ago"
        }

        if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1h ago" : "\(hours)h ago"
        }

        if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1m ago" : "\(minutes)m ago"
        }

        return "just now"
    }
}
