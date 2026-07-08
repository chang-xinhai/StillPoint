import Foundation

extension TimeInterval {
    var shortDurationString: String {
        let totalSeconds = max(0, Int(self.rounded()))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        if minutes == 0 {
            return "\(seconds)s"
        }

        if seconds == 0 {
            return "\(minutes)m"
        }

        return "\(minutes)m \(seconds)s"
    }
}

extension Date {
    var shortTimeString: String {
        Self.timeFormatter.string(from: self)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

