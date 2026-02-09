import Foundation

enum OEEEngine {
    /// Availability = (Run Time / Planned Production Time) * 100
    static func availability(plannedTime: Double, downtime: Double) -> Double {
        guard plannedTime > 0 else { return 0 }
        return ((plannedTime - downtime) / plannedTime) * 100.0
    }

    /// Performance = (Ideal Cycle Time * Total Count / Run Time) * 100
    static func performance(idealCycleTime: Double, totalCount: Double, runTime: Double) -> Double {
        guard runTime > 0 else { return 0 }
        return (idealCycleTime * totalCount / runTime) * 100.0
    }

    /// Quality = (Good Count / Total Count) * 100
    static func quality(totalCount: Double, defectCount: Double) -> Double {
        guard totalCount > 0 else { return 0 }
        return ((totalCount - defectCount) / totalCount) * 100.0
    }

    /// OEE = Availability * Performance * Quality / 10000
    static func oee(availability: Double, performance: Double, quality: Double) -> Double {
        return (availability * performance * quality) / 10000.0
    }

    /// Interpretation of OEE value
    static func interpretation(_ oee: Double) -> String {
        if oee >= 85 {
            return String(localized: "oee.interpretation.worldClass")
        } else if oee >= 60 {
            return String(localized: "oee.interpretation.typical")
        } else if oee >= 40 {
            return String(localized: "oee.interpretation.low")
        } else {
            return String(localized: "oee.interpretation.veryLow")
        }
    }
}
