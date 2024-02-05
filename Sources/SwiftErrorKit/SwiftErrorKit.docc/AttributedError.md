# Error attribution

Attribute errors using built-in attribute types, as well as your custom attributes.

## Overview

The same type of error (e.g. UnexpectedNil) can result from different failures. Conversely,
the same failure may gain different meanings in different contexts as it is propagated towards
its point of consumption.

Error attribution allows for the addition of tangential information to the error,
based on contexts in which it occurs during propagation, to enhance its categorization,
tracking, quality of metadata, or message conveyance.

You can attribute an error via ``Swift/Error/attribute(_:fileID:line:)`` and retrieve these
attributes either through ``Swift/Error/attribute(of:)`` for the latest attribute of given
type or ``Swift/Error/attributes(of:)`` for all attributes of that type, sorted in _FILO_ order.

You can attribute an error in a factory initialization:
```swift
struct Whoops: Error {
    private init() {}
    static func make<each T>(
        _ debugInfo: repeat each T,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) -> any Error {
        Whoops().attribute(
            .debugInfo(repeat each T),
            .severity(.critical),
            .rank(.urgent)
            fileID: fileID,
            line: line
        )
    }
}
```
On throw:
```swift
func prepareWorkflow<T: Workflow>(_ workflow: T) throws -> T {
    guard let template = templates[workflow.templateID] else {
        throw UnexpectedNil().attribute(
            .severity(.info),
            .tag(Component.workflows),
            .source(.internal)
        )
    }
    ...
}
```
In any scope it occurs...:
```swift
do {
    guard session.hasPermission(to: approval.license) else {
        throw Forbidden().attribute(
            .debugInfo(approval.license, session.permissions),
            .userLevel(.warning),
            .rank(.low),
            .localize(message: "You don't have access to this approval owned by \(approval.manager).")
        )
    }
    do { 
        try workflowManager.prepareWorkflow(approval)
    } catch {
        throw error.attribute(
            .debugInfo(approvalsProvider.clients, workflowManager.state, whateverUsefulContext),
            .severity(.internal),
            .rank(.high)
        )
    }
} catch {
    throw error.attribute(.tag(Feature.approvals))
}
```
Retrieve attributes via ``Swift/Error/attribute(of:)`` or ``Swift/Error/attributes(of:)``.
```swift
extenstion Error {
    func report() {
        MyMonitoringSystem.send { payload in
            payload.originalError = base
            // `highestRank` is `attributes(of: RankErrorAttribute.self).map(\.0).max()` convenience.
            payload.priority = highestRank
            // `tags(of:)` is `attributes(of: TagErrorAttribute<T>.self).map({ $0.0.tag })` convenience.
            payload.features = tags(of: Feature.self)?.map { String($0) }
            // Similarly, `tags`, `severity` and `debugInfo` are just conveniences over 
            // `attribute(of:)` and `attributes(of:)`.
            payload.labels = tags?.map { String($0) }
            payload.severity = severity
            payload.additionalInfo = String(debugInfo)
            payload.errorID = String(identifiable.id)
            ...
            return payload
        }
    }

    /// Meant for conveying to UI.
    var userInfo: (title: String, message: String, level: UserLevelErrorAttribute?, id: String) {
        (
            localization.title ?? "Uh oh",
            localization.message ?? "Something went wrong",
            userLevel,
            String(identifiable.id)
        )
    }
}
```

You can think of error attributes as of properties of an error instace,
rather than being exclusive to the error type itself.
This error attribution is a scalable system around
every error type, even those that you don't own; allowing you for common error
properties (attributes) for any error you encounter in your system.
Use it to:
* Categorize by arbitrary quality, like severity, priority, component, feature,
source, state, ...
* Attach valuable debug info or metadata.
* Attach valuable user info.
* Track source provenance and propagation locations up to the point of consumption.
* Track errors as identified instances.
* Report collected relevant attributes to your error monitoring system.
* Convey valuable user info to the UI.
* ...


### API overview

* Attributing an error and retrieving the attributes is via ``Swift/Error`` interface.
* List of built-in error attributes is in <doc:#Error-Attributes> section.
* Creating your own error attributes via ``ErrorAttribute`` protocol.


## Detailed design

Any ``Swift/Error/attribute(_:fileID:line:)`` or ``Swift/Error/identifiable`` transforms the error into
opaque _AttributedError_. This internal type is just a wrapper over the error that contains also the
id and attributes.

> Important:
Since most `any Error`s are now likely an opaque _AttributedError_, you should always use `Error`.``Swift/Error/base``
if you need to access the original error.

Printing an attributed error can give you an idea in what structure it is transformed into:
```swift
let error = Whoops(badThing: "foo")
    .attribute(
        .tag(Color.pink),
        .severity(.warning)
    )
    .attribute(
        .localization(title: "Uh oh", message: "Too many cats!"),
        .tag("feature:cats"),
        .severity(.critical)
    )
print(error)
```
prints
```
_AttributedError {
    base<Whoops>: Whoops(badThing: "foo")
    id<UUID>: 19BC1420-6397-4EEB-8C46-18287F764FAB
    attributes: (SeverityErrorAttribute, TagErrorAttribute<String>, LocalizationErrorAttribute, SeverityErrorAttribute, TagErrorAttribute<Color>) [
        @SwiftErrorKitTests/SwiftErrorKitTests.swift:24
        - Severity:
            - critical
        - Tag<String>:
            - feature:cats
        - Localization:
            - Title: Uh oh
            - Message: Too many cats!
        @SwiftErrorKitTests/SwiftErrorKitTests.swift:20
        - Severity:
            - warning
        - Tag<Color>:
            - pink
    ]
}
```
Things to notice:
* _AttributedError_ wraps the original error (`base`) and contains also information about `id` and `attributes`.
You access the original error via ``Swift/Error/base``.
* _AttributedError_ is always `Swift.Identifiable`. The concrete `ID` type is `Base.ID` if `Base` conforms
to `Identifiable`, `Foundation.UUID` otherwise (see ``Swift/Error/identifiable``). Since `Whoops`
doesn't conform to `Swift.Identifiable` in this example, _AttributedError_ creates an instance identifier of
`UUID`. So `error.identified.id` would return `A30D329A-6C53-4798-B0AA-9EF2F676167E` of `UUID`.
* Attributes are sorted in _FILO_, i.e. latest `severity` is `.critical`.
* Every attribution has its source location. The info about source location is part of return value in both
``Swift/Error/attribute(of:)`` and ``Swift/Error/attributes(of:)``.
* ``ErrorAttribute`` requirements allows _AttributedError_ to be "pretty printed".

## Error Attributes

The package comes with some common built-in attributes:
* ``DebugInfoErrorAttribute``
* ``LocalizationErrorAttribute``
* ``RankErrorAttribute``
* ``SeverityErrorAttribute``
* ``SourceErrorAttribute``
* ``TagErrorAttribute``
* ``TagErrorAttribute``
* ``UserLevelErrorAttribute``


#### Creating your custom attributes

If the built-in attributes don't suite all your needs, the package defines ``ErrorAttribute`` protocol
so you can create your custom-tailored attribute types.



## Future directions (TODO)

* Provide `Swift.Identifiable` generator middleware so clients can set their preffered default `ID` type.
This would also lift depencency on `Foundation`.

* Add `RecoveryActionsErrorAttribute`.

* Add support for `LocalizedStringResource` in ``LocalizationErrorAttribute`` if `Foundation` is available.

* Consider adding support for disabling source provenance tracking, or introduce a redacting mechanism,
to facilitate use in high-security environments.


## Random notes

* Swift is getting typed throws but the error type system remains weak. That's why 
``Swift/Error/attribute(_:fileID:line:)`` can't return generic type but just `any Error`.
The type is fully generic internally though, the base error, identifier and attributes
type information is preserved. It has no use ATM though.
