# SwiftErrorKit

SwiftPM package: https://github.com/stansmida/swift-error-kit.git

## TL;DR

`SwiftErrorKit` provides:
- Error attribution
```swift
throw Whoops().attribute(
    .tag(Feature.workflows),
    .severity(.error),
    .rank(.low),
    .localization(message: "Foo is wrong."),
    .debugInfo(workflowManager.state, aContext, anotherContext)
)
```

See more in [the documentation](http://stansmida.github.io/swift-error-kit).
