import Foundation

enum AQLEngine {
    struct SamplingPlan {
        let codeLetter: String
        let sampleSize: Int
        let acceptNumber: Int
        let rejectNumber: Int
    }

    /// Get code letter from lot size and inspection level
    static func codeLetter(lotSize: Int, inspectionLevel: String = "II") -> String? {
        for entry in AppConstants.AQL.codeLetter {
            if lotSize >= entry.min && lotSize <= entry.max {
                switch inspectionLevel {
                case "S-1": return entry.S1
                case "S-2": return entry.S2
                case "S-3": return entry.S3
                case "S-4": return entry.S4
                case "I": return entry.I
                case "II": return entry.II
                case "III": return entry.III
                default: return entry.II
                }
            }
        }
        return nil
    }

    /// Get sample size from code letter
    static func sampleSize(codeLetter: String) -> Int? {
        AppConstants.AQL.sampleSize[codeLetter]
    }

    /// Get accept/reject numbers from code letter and AQL value
    static func acceptReject(codeLetter: String, aql: Double) -> (accept: Int, reject: Int)? {
        guard let entries = AppConstants.AQL.normalTable[codeLetter] else { return nil }

        // Find AQL index
        guard let aqlIndex = AppConstants.AQL.aqlValues.firstIndex(of: aql) else { return nil }
        guard aqlIndex < entries.count else { return nil }

        let (ac, re) = entries[aqlIndex]
        guard ac >= 0 && re >= 0 else { return nil } // -1 means not applicable

        return (accept: ac, reject: re)
    }

    /// Full sampling plan lookup
    static func samplingPlan(lotSize: Int, inspectionLevel: String = "II", aql: Double) -> SamplingPlan? {
        guard let code = codeLetter(lotSize: lotSize, inspectionLevel: inspectionLevel),
              let size = sampleSize(codeLetter: code),
              let ar = acceptReject(codeLetter: code, aql: aql) else { return nil }

        return SamplingPlan(
            codeLetter: code,
            sampleSize: size,
            acceptNumber: ar.accept,
            rejectNumber: ar.reject
        )
    }

    /// Available inspection levels
    static let inspectionLevels = ["I", "II", "III"]
}
