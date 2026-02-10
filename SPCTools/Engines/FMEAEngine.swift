import Foundation

enum FMEAEngine {
    struct FMEAItem: Identifiable {
        let id = UUID()
        let failureMode: String
        let severity: Int
        let occurrence: Int
        let detection: Int
        let rpn: Int
        let priority: String
    }

    /// RPN = Severity × Occurrence × Detection
    static func rpn(severity: Int, occurrence: Int, detection: Int) -> Int {
        severity * occurrence * detection
    }

    /// Priority based on RPN
    static func priority(rpn: Int) -> String {
        if rpn >= 200 {
            return String(localized: "fmea.priority.high")
        } else if rpn >= 120 {
            return String(localized: "fmea.priority.medium")
        } else {
            return String(localized: "fmea.priority.low")
        }
    }

    /// Create FMEA item
    static func createItem(failureMode: String, severity: Int, occurrence: Int, detection: Int) -> FMEAItem {
        let r = rpn(severity: severity, occurrence: occurrence, detection: detection)
        return FMEAItem(
            failureMode: failureMode,
            severity: clamp(severity),
            occurrence: clamp(occurrence),
            detection: clamp(detection),
            rpn: r,
            priority: priority(rpn: r)
        )
    }

    /// Sort items by RPN descending
    static func sortByRPN(_ items: [FMEAItem]) -> [FMEAItem] {
        items.sorted { $0.rpn > $1.rpn }
    }

    /// Clamp value to 1-10 range
    static func clamp(_ value: Int) -> Int {
        max(1, min(10, value))
    }
}
