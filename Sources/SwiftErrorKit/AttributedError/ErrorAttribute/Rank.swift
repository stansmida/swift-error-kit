/// An error attribute to assign a tracked issue a priority.
///
/// You can assign an error a level of importance (to address it)
/// regardless of its severity. For instance, an issue with `.error`
/// severity might be given a different priority based on the importance
/// of the service in which it occurs.
///
/// - SeeAlso: ``SeverityErrorAttribute`` and ``UserLevelErrorAttribute``.
public enum RankErrorAttribute: String, Comparable, ErrorAttribute {

    case low
    case medium
    case high
    case urgent

    public static func < (lhs: RankErrorAttribute, rhs: RankErrorAttribute) -> Bool {
        lhs.level < rhs.level
    }

    private var level: Int {
        switch self {
            case .low: 0
            case .medium: 1
            case .high: 2
            case .urgent: 3
        }
    }

    public var typeDescription: String { "Rank" }

    public var valueDescription: [String] { [rawValue] }
}

public extension ErrorAttribute where Self == RankErrorAttribute {

    static func rank(_ rank: RankErrorAttribute) -> RankErrorAttribute {
        rank
    }
}

public extension Error {

    var highestRank: RankErrorAttribute? {
        attributes(of: RankErrorAttribute.self).map(\.0).max()
    }

    var rank: RankErrorAttribute? {
        attribute(of: RankErrorAttribute.self)?.0
    }
}
