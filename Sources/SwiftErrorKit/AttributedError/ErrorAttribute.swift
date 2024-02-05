/// A type that represents an error attribute.
///
/// The package offers some fundamental attributes for use,
/// but you can create your own, custom-tailored for your project.
public protocol ErrorAttribute {

    /// Cutom type description for a more readable `AttributedError` description.
    /// 
    /// E.g. you can return "Tag<\(Tag.self)>" for `TagErrorAttribute`.
    var typeDescription: String { get }

    /// Custom value description for a more readable `AttributedError` description.
    /// 
    /// Can be represented as multiple values, especially in types that contain multiple properties.
    /// E.g. see implementation of `LocalizationErrorAttribute`.``LocalizationErrorAttribute/valueDescription``.
    var valueDescription: [String] { get }
}

public extension ErrorAttribute {

    var typeDescription: String { String(describing: Self.self) }

    var valueDescription: [String] { [String(describing: self)] }
}
