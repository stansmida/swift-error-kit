/// An error attribute to express error severity in your system.
///
/// - Note: This set of severity levels is small on purpose. Any error can fit into one of these levels.
/// If you are not sure, and need to indicate different kind od level (e.g. unknown, to-triage, debug, ...),
/// you can leave this `nil` and dedicate your custom tag (e.g. `TagErrorAttribute<OurInternalSeverity>`) to it.
/// If the set doesn't fit your convention at all, do not hesitate to create your custom ``ErrorAttribute``
/// to categorize by your custom severity level.
///
/// - Note: This type is supposed to rank issues in your system. For instance, an invalid input from
/// user is typically `.info` in your system, but `.error` for user. So you would rank it as `.info`,
/// while you may want to also add ``UserLevelErrorAttribute/error``
/// to attribute level from user perspective.
/// Also, severity is not priority - use ``RankErrorAttribute`` to rank importance.
///
/// - SeeAlso: ``RankErrorAttribute`` and ``UserLevelErrorAttribute``.
public enum SeverityErrorAttribute: String, Comparable, ErrorAttribute {

    /// Zero or negligible severity.
    case info
    case warning
    case error
    case critical

    public static func < (lhs: SeverityErrorAttribute, rhs: SeverityErrorAttribute) -> Bool {
        lhs.level < rhs.level
    }

    private var level: Int {
        switch self {
            case .info: 0
            case .warning: 1
            case .error: 2
            case .critical: 3
        }
    }

    public var typeDescription: String { "Severity" }

    public var valueDescription: [String] { [rawValue] }
}

public extension ErrorAttribute where Self == SeverityErrorAttribute {

    static func severity(_ severity: SeverityErrorAttribute) -> SeverityErrorAttribute {
        severity
    }
}

public extension Error {

    var highestSeverity: SeverityErrorAttribute? {
        attributes(of: SeverityErrorAttribute.self).map(\.0).max()
    }

    var severity: SeverityErrorAttribute? {
        attribute(of: SeverityErrorAttribute.self)?.0
    }
}
