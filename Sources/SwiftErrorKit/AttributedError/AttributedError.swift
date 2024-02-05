import Foundation
import SwiftExtras

/// Private helper protocol that helps to bind `AttributedError` from `any Error` and
/// use its interface without need to being specific about its generic types.
private protocol _AttributedError {

    var baseAny: any Error { get }
    func add<each T>(_ newAttribute: repeat each T, sourceProvenance: SourceProvenance) -> any Error where repeat each T: ErrorAttribute
    func addSingle<T>(_ newAttribute: T, sourceProvenance: SourceProvenance) -> any _AttributedError where T: ErrorAttribute
    func attribute<T>(of type: T.Type) -> (T, SourceProvenance)?
    func attributes<T>(of type: T.Type) -> [(T, SourceProvenance)]
}

/// A containder for attached error attributes to its underlying base (provenance) error.
///
/// See <doc:AttributedError> article.
///
/// - Todo: Remove tuple wrap [once this restriction is eliminated](https://github.com/apple/swift-evolution/blob/main/proposals/0398-variadic-types.md#future-directions).
internal struct AttributedError<Base, ID, each Attribute>: _AttributedError, CustomStringConvertible, Error, Identifiable where Base: Error, ID: Hashable, repeat each Attribute: ErrorAttribute {

    fileprivate init(base: Base, id: ID, attribute: repeat (each Attribute, SourceProvenance)) {
        self.base = base
        self.id = id
        self.attribute = (repeat each attribute)
    }

    public let base: Base
    public let id: ID
    public let attribute: (repeat (each Attribute, SourceProvenance))

    // MARK: _AttributedError

    fileprivate var baseAny: any Error {
        base
    }

    fileprivate func add<each T>(_ anotherAttribute: repeat each T, sourceProvenance: SourceProvenance) -> any Error where repeat each T: ErrorAttribute {
        var e: any _AttributedError = self
        repeat _add((each anotherAttribute), sourceProvenenace: sourceProvenance, to: &e)
        return e as! any Error
    }

    private func _add<T>(_ anotherAttribute: T, sourceProvenenace: SourceProvenance, to: inout (any _AttributedError)) where T: ErrorAttribute {
        to = to.addSingle(anotherAttribute, sourceProvenance: sourceProvenenace)
    }

    fileprivate func addSingle<T>(_ newAttribute: T, sourceProvenance: SourceProvenance) -> any _AttributedError where T : ErrorAttribute {
        SwiftErrorKit.AttributedError(base: base, id: id, attribute: (newAttribute, sourceProvenance), repeat each attribute)
    }

    /// - Todo: Pack iteration once it is available.
    fileprivate func attribute<T>(of type: T.Type) -> (T, SourceProvenance)? {
        attributes(of: type).first
    }

    /// - Todo: Pack iteration once it is available.
    fileprivate func attributes<T>(of type: T.Type) -> [(T, SourceProvenance)] {
        func addAttribute<U, V>(_ attribute: U, sourceProvenance: SourceProvenance, to: inout [(V, SourceProvenance)]) {
            if let attribute = attribute as? V {
                to.append((attribute, sourceProvenance))
            }
        }
        var r = [(T, SourceProvenance)]()
        repeat addAttribute((each attribute).0, sourceProvenance: (each attribute).1, to: &r)
        return r
    }

    // MARK: CustomStringConvertible

    public var description: String {
        """
        _AttributedError {
            base<\(Base.self)>: \(base)
            id<\(ID.self)>: \(id)
            attributes: \(type(of: (repeat (each attribute).0))) [
        \(attributesDescription)
            ]
        }
        """
    }

    /// - Todo: Pack iteration once it is available.
    private var attributesDescription: String {
        func addAttributeDescription<T>(_ attribute: T, _ sourceProvenance: SourceProvenance, last: inout SourceProvenance?, to result: inout [String]) where T: ErrorAttribute {
            if last != sourceProvenance {
                last = sourceProvenance
                result.append("\t\t@\(sourceProvenance)")
            }
            result.append("\t\t- \(attribute.typeDescription):")
            for value in attribute.valueDescription {
                result.append("\t\t\t- \(value)")
            }
        }
        var last: SourceProvenance?
        var r = [String]()
        repeat addAttributeDescription((each attribute).0, (each attribute).1, last: &last, to: &r)
        return r.joined(separator: "\n")
    }
}

public extension Error {

    /// Returns the original error. `self` if `self` is the original error.
    /// - Important: Once you start using error attributes, you should expect vast majority of `any Error` values
    /// to be _AttributedError_. Everytime you need to work with the original error, you retrieve it
    /// through this accessor.
    /// - SeeAlso: You can find more info about the concept of _AttributedError.Base_ in <doc:AttributedError>.
    var base: any Error {
        if let attributedError = self as? any _AttributedError {
            attributedError.baseAny
        } else {
            self
        }
    }

    /// `base` if the original error is `Swift.Identifiable`, internal _AttributedError_ that is by default
    /// an identified instance otherwise.
    ///
    /// If the original error doesn't conform to `Swift.Identifiable`, the _AttributedError_ identifies
    /// the instance with a generated `Foundation.UUID`. You can use this value to track error instances.
    /// For example, you could provide the error ID to the user, so you can locate the exact error they
    /// encountered in your monitoring system.
    ///
    /// `let errorID = anyError.identifiable.id`
    ///
    /// - SeeAlso: You can find more info about the concept of _AttributedError.ID_ in <doc:AttributedError>.
    ///
    /// - Todo: Provide `Swift.Identifiable` generator middleware so clients can set their preffered
    /// default `ID` type. This would also lift depencency on `Foundation`
    var identifiable: any (Error & Identifiable) {
        if let identifiable = self as? any (Error & Identifiable) {
            identifiable
        } else {
            AttributedError(base: self, id: UUID())
        }
    }

    /// Add attributes to the error.
    ///
    /// The `attribute` parameter is variadic, so you can add as many various `ErrorAttribute` values as you want:
    /// ```swift
    /// error.attribute(
    ///     .severity(.warning),
    ///     .localization(message: "Oi oi"),
    ///     .rank(.low),
    ///     .tag(Feature.form),
    ///     .tag("sprint:13"),
    ///     ...
    /// )
    /// ```
    func attribute<each T>(_ attribute: repeat each T, fileID: StaticString = #fileID, line: UInt = #line) -> any Error where repeat each T: ErrorAttribute {
        var attributedError: (any _AttributedError)!
        if let selfAtrributedError = self as? any _AttributedError {
            attributedError = selfAtrributedError
        } else if let identifiableError = self as? any (Error & Identifiable) {
            attributedError = identifiableError.attributedError
        } else {
            attributedError = AttributedError(base: self, id: UUID())
        }
        return attributedError.add(repeat each attribute, sourceProvenance: .init(fileID, line))
    }

    /// Returns the latest attribute of the given type, along with information about
    /// the source location where it was added.
    ///
    /// - SeeAlso: ``Swift/Error/attributes(of:)``
    ///
    /// - Note: Ideally, accessing attributes would be through dynamic member
    /// lookup with key paths (of a scope type (pattern similar to
    /// `Foundation.AttributeScopes`)) but retroactive dynamic member lookup
    /// (i.e. `extension @dynamicMemberLookup Error { ...`) isn't supported. Extending `Error`
    /// with accessor property that will use this method isn't more inconvenient than registering
    /// to the scope though:
    /// ```
    /// public extension Error {
    ///     var severity: SeverityErrorAttribute? {
    ///         attribute(of: SeverityErrorAttribute.self)
    ///     }
    /// }
    /// ```
    func attribute<T>(of type: T.Type) -> (T, sourceProvenance: SourceProvenance)? {
        if let attributedError = self as? any _AttributedError {
            attributedError.attribute(of: type)
        } else {
            nil
        }
    }

    /// Returns all attributes of the given type in _FILO_ order (latest is first),
    /// along with information about the source location where they were added.
    ///
    /// Some attribute types, like for instance ``TagErrorAttribute`` or ``DebugInfoErrorAttribute``
    /// are of a rather 'cumulative' nature and you may want to retrieve them all.
    /// Conversely, some, like for instance ``RankErrorAttribute``, are of a rather 'transformative'
    /// nature, where you might want to retrieve just the latest attribute, via ``Swift/Error/attribute(of:)``,
    /// assuming it represents the most significant or most up-to-date value of the given attribute type.
    /// However, you may still want to retrieve all ranks, for instance, to find the highest rank
    /// (e.g. ``Swift/Error/highestRank`` implementation).
    ///
    /// - SeeAlso: ``Swift/Error/attribute(of:)`` for retrieving just single latest attribute
    /// of given type.
    ///
    /// - Note: Generic constraint `where T: ErrorAttribute` is omitted on purpose.
    /// This allows to pass also types that are not concrete ``ErrorAttribute`` but related,
    /// which you may need when asking for generic attributes without being specific about the
    /// generic parameter. A typical example is `TagErrorAttribute<Tag>: _TagErrorAttributeProtocol`
    /// which attributes can client access not only by specific type with
    /// `Error.attribute(of: TagErrorAttribute<URL>.self)` but also any tags with
    /// `Error.attribute(of: (any _TagErrorAttributeProtocol).self)`.
    func attributes<T>(of type: T.Type) -> [(T, sourceProvenance: SourceProvenance)] {
        if let attributedError = self as? any _AttributedError {
            attributedError.attributes(of: type)
        } else {
            []
        }
    }
}

private extension Identifiable where Self: Error {

    /// Creates `AttributedError` with identity of the `Base` (`Self`) error.
    /// We need to do this from `Identifiable.Self` because in most cases
    /// we are dealing with erased `any Error` values, so `ID` is erased.
    var attributedError: any _AttributedError {
        AttributedError(base: self, id: id)
    }
}
