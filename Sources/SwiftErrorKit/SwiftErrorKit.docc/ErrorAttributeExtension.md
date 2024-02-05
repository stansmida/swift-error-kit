# ``ErrorAttribute``


## Discussion


### Creating your `ErrorAttribute` (e.g. `ImpacteeErrorAttribute`) checklist:

Consider if you really want to create your own attribute type or passing your custom type
to ``TagErrorAttribute`` `<Impactee>` would do. The ``TagErrorAttribute`` is a powerful
error attribute, that can carry arbitrary types, making it a considerable option for simple types
that can represent your attribute.

1. Implement ``ErrorAttribute/typeDescription-24pqx`` and ``ErrorAttribute/valueDescription-7j95e`` for better
_AttributedError_ readability (see <doc:AttributedError#Detailed-design> how it pretty-prints):
```swift
struct ImpacteeErrorAttribute: ErrorAttribute {
    let region: Region
    let devices: Set<DeviceType>
    var typeDescription: String { "Impactee" }
    var typeDescription: String { [
        "Region: \(region)",
        "Devices: \(devices)"
    ] }
}
```
If the attribute contains complex structure types, consider conforming these types
to `CustomStringConvertible`.

2. Consider your type methods extension for convenience:
```swift
public extension ErrorAttribute where Self == ImpacteeErrorAttribute {

    static func impactee(region: Region, devices: Set<DeviceType>) -> ImpacteeErrorAttribute {
        ImpacteeErrorAttribute(region: region, devices: devices)
    }
}
```
this small convenience will allow you for leading dot syntax autocompletion:
```swift
error.attribute(.impactee(region: .eu1, devices: [.mobile]))
```
in comparison to
```swift
error.attribute(ImpacteeErrorAttribute(region: .eu1, devices: [.mobile]))
```

3. Consider providing retrieval convenience:
```swift
extension Error {
    var impactee: ImpacteeErrorAttribute? {
        attribute(of: ImpacteeErrorAttribute.self)?.0
    }
}
```
