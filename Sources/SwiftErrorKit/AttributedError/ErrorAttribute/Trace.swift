import SwiftExtras

/// An error attribute to track a source location.
public struct TraceErrorAttribute: ErrorAttribute {

    public init(_ fileID: StaticString = #fileID, _ line: UInt = #line, _ column: UInt = #column) {
        sourceProvenance = .init(fileID, line, column)
    }

    fileprivate let sourceProvenance: SourceProvenance

    public var typeDescription: String { "Trace" }

    public var valueDescription: [String] { [String(describing: sourceProvenance)] }
}

public extension ErrorAttribute where Self == TraceErrorAttribute {

    static func trace(_ fileID: StaticString = #fileID, _ line: UInt = #line, _ column: UInt = #column) -> Self {
        TraceErrorAttribute(fileID, line, column)
    }
}

public extension Error {

    var trace: [SourceProvenance] {
        attributes(of: TraceErrorAttribute.self).map(\.0.sourceProvenance)
    }
}
