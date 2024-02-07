# ``SwiftErrorKit``

Error attribution and commons. 

#### _SwiftErrorKit_ is distributed as a _SwiftPM_ package 

[Go to the package page: https://github.com/stansmida/swift-error-kit.git](https://github.com/stansmida/swift-error-kit.git)


## Overview

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


## Topics


### Error attribution

- <doc:AttributedError>


### Attributing an error and retrieving the attributes 

- ``Swift/Error``


### Error attributes in the package

- ``DebugInfoErrorAttribute``
- ``LocalizationErrorAttribute``
- ``RankErrorAttribute``
- ``SeverityErrorAttribute``
- ``SourceErrorAttribute``
- ``TagErrorAttribute``
- ``TraceErrorAttribute``
- ``UserLevelErrorAttribute``


### Creating your custom error attributes

- ``ErrorAttribute``
