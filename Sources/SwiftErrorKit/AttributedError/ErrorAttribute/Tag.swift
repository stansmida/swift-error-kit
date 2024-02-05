private protocol _TagErrorAttributeProtocol<Tag> {
    associatedtype Tag
    var tag: Tag { get }
}

/// An error attribute to assign a tag to an error.
///
/// Assign an error custom tags (labels) for tracking or categorization. These may be features, URLs, epics,
/// components, source namespaces, context object ids, whatever...
/// This attribute is generic, so you can pass it just a string or a custom type that can serve as a scope
/// for your tag type.
///
/// The generic nature of this attribute type makes it a considerable alternative to your custom attribute type.
public struct TagErrorAttribute<Tag>: _TagErrorAttributeProtocol, ErrorAttribute {

    public init(_ tag: Tag) {
        self.tag = tag
    }

    public let tag: Tag

    public var typeDescription: String { "Tag<\(Tag.self)>" }

    public var valueDescription: [String] { [String(describing: tag)] }
}

public extension ErrorAttribute {

    static func tag<Tag>(_ tag: Tag) -> Self where Self == TagErrorAttribute<Tag> {
        TagErrorAttribute(tag)
    }
}

public extension Error {

    var tags: [Any] {
        attributes(of: (any _TagErrorAttributeProtocol).self).map({ $0.0.tag as Any })
    }

    func tags<T>(of _: T.Type) -> [T] {
        attributes(of: TagErrorAttribute<T>.self).map({ $0.0.tag })
    }
}
