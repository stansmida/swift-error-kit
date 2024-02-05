/// An error attribute to provide a localized user message.
///
/// It's a kind of alternative to `LocalizedError` which has some disadvantages:
/// + `LocalizedError` requires the localization values on initialization. This works ok
/// for general messages, but can be limiting to provide more descriptive messages due to
/// limited context.
/// + It's paradoxical that in a limited context, `LocalizedError` has four properties which,
/// in my opinion, form an ambiguous API. It leads to noise rather than guiding
/// the writing of concise messages. Also, I'm not aware of any interface within the SDK
/// that conveys those properties of `LocalizedError` to the UI seamlessly.
/// + Requires to import `Foundation`.
///
/// On the other hand, this lightweight approach enables the localization of an error
/// at any point of its existence, from the throw site up to where it is consumed.
/// It also allows for the override or adjustment of any previous localization to better
/// reflect the context in which the error is being propagated.
///
/// - Todo: Add support for `LocalizedStringResource` if `Foundation` is available.
public struct LocalizationErrorAttribute: ErrorAttribute {
    
    public init(title: String? = nil, message: String) {
        self.title = title
        self.message = message
    }

    let title: String?
    let message: String

    public var typeDescription: String { "Localization" }
    public var valueDescription: [String] {
        var result = [String]()
        if let title {
            result.append("Title: \(title)")
        }
        result.append("Message: \(message)")
        return result
    }
}

#if canImport(Foundation)
import Foundation

extension AttributedError: LocalizedError {

    public var errorDescription: String? {
        localization?.message
    }
}
#endif


public extension ErrorAttribute where Self == LocalizationErrorAttribute {

    static func localization(
        title: String? = nil,
        message: String
    ) -> LocalizationErrorAttribute {
        LocalizationErrorAttribute(title: title, message: message)
    }
}

public extension Error {

    var localization: LocalizationErrorAttribute? {
        attribute(of: LocalizationErrorAttribute.self)?.0
    }
}
