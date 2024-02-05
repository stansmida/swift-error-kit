import SwiftExtras

private protocol _DebugInfoErrorAttributeProtocol {
    var compatibleDebugInfo: [Any] { get }
}

/// An error attribute to include custom debug info.
/// - Todo: Remove tuple wrap [once this need is eliminated](https://github.com/apple/swift-evolution/blob/main/proposals/0398-variadic-types.md#future-directions).
public struct DebugInfoErrorAttribute<each T>: _DebugInfoErrorAttributeProtocol, ErrorAttribute {

    public init(_ debugInfo: repeat each T) {
        self.debugInfo = (repeat each debugInfo)
    }

    public let debugInfo: (repeat each T)

    public var typeDescription: String { "Debug info" }

    public var valueDescription: [String] {
        compatibleDebugInfo.map({ "\($0)" })
    }

    /// - Todo: Pack iteration once it is available.
    fileprivate var compatibleDebugInfo: [Any] {
        func add<U>(_ value: U, to result: inout [Any]) {
            result.append(value)
        }
        var result = [Any]()
        repeat add(each debugInfo, to: &result)
        return result
    }
}

public extension ErrorAttribute {

    static func debugInfo<each T>(
        _ debugInfo: repeat each T
    ) -> DebugInfoErrorAttribute<repeat each T> where Self == DebugInfoErrorAttribute<repeat each T> {
        DebugInfoErrorAttribute(repeat each debugInfo)
    }
}

public extension Error {

    var debugInfo: [([Any], sourceProvenance: SourceProvenance)] {
        attributes(of: (any _DebugInfoErrorAttributeProtocol).self)
            .map({ ($0.0.compatibleDebugInfo, $0.sourceProvenance) })
    }
}
