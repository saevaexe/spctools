import Foundation

extension Double {
    var formatted2: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    var formattedEngineering: String {
        if self >= 1_000_000 {
            return "\((self / 1_000_000).formatted2) M"
        } else if self >= 1_000 {
            return "\((self / 1_000).formatted2) k"
        } else if self < 0.001 && self > 0 {
            return "\((self * 1_000).formatted2) m"
        }
        return formatted2
    }
}
