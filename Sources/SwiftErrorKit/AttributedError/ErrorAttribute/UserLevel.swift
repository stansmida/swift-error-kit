/// An error attribute to express error level from user perspective.
///
/// Error levels in your system may have different significance for user and should
/// be assessed separately.
/// For instance, invalid input to a field that prevents from continue is typically
/// an `error` from user perspective while ``SeverityErrorAttribute/info``
/// in your system. Set this attribute to use it later when conveying the error
/// to the user.
///
/// You can use this attribute alongside ``LocalizationErrorAttribute`` to convey
/// information with a richer UX.
public enum UserLevelErrorAttribute: String, Comparable, ErrorAttribute {

    /// Typically propagated as information (blue ℹ️).
    /// E.g. "Cancelled" or a timely notifivation about why cannot proceed.
    case info
    /// Typically propagated as a warning (yellow ⚠️).
    /// E.g. "Ok, but..."
    case warning
    /// Typically propagated as an error (red 🛑).
    case error

    public static func < (lhs: UserLevelErrorAttribute, rhs: UserLevelErrorAttribute) -> Bool {
        lhs.level < rhs.level
    }

    private var level: Int {
        switch self {
            case .info: 0
            case .warning: 1
            case .error: 2
        }
    }

    public var typeDescription: String { "User level" }

    public var valueDescription: [String] { [rawValue] }
}

public extension ErrorAttribute where Self == UserLevelErrorAttribute {

    static func userLevel(_ userLevel: UserLevelErrorAttribute) -> UserLevelErrorAttribute {
        userLevel
    }
}

public extension Error {

    var userLevel: UserLevelErrorAttribute? {
        attribute(of: UserLevelErrorAttribute.self)?.0
    }
}
