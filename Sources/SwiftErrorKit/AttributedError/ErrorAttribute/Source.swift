/// An error attribute to include information about the high-level component
/// in which the error emerged.
public enum SourceErrorAttribute: String, ErrorAttribute {

    /// Error in internal application.
    /// Logic error, bug, or issue with internal operation, ...
    case `internal`
    /// "Internal" error in external application.
    /// Third-party API or service failure, unexpected behavior, ...
    case external
    /// Error resulting from user interaction or input data problem.
    /// Invalid input data, form submission error, user request error, ...
    case input
    /// Error caused by a system that the process runs on.
    /// Hardware failure, OS-level error, resource exhaustion,
    /// environment configuration, ...
    case system
    /// Communication error.
    /// Network outage, connectivity problem, protocol error, ...
    case io

    public var typeDescription: String { "Source" }

    public var valueDescription: [String] { [rawValue] }
}

public extension ErrorAttribute where Self == SourceErrorAttribute {

    static func source(_ source: SourceErrorAttribute) -> Self {
        source
    }
}

public extension Error {

    var source: SourceErrorAttribute? {
        attribute(of: SourceErrorAttribute.self)?.0
    }
}
