# ``Swift/Error``

``Swift/Error`` extensions.

## Overview

You don’t directly work with _AttributedError_; instead, you work with ``Swift/Error``.
See examples and detailed design in <doc:AttributedError>.

## Topics

### Attributing an error and retrieving the attributes

- ``Swift/Error/attribute(_:fileID:line:)``
- ``Swift/Error/attribute(of:)``
- ``Swift/Error/attributes(of:)``

### Another properties of _AttributedError_

- ``Swift/Error/base``
- ``Swift/Error/identifiable``

### Conveniences on the package error attributes

- ``Swift/Error/debugInfo``
- ``Swift/Error/localization``
- ``Swift/Error/rank``
- ``Swift/Error/highestRank``
- ``Swift/Error/severity``
- ``Swift/Error/highestSeverity``
- ``Swift/Error/source``
- ``Swift/Error/tags``
- ``Swift/Error/tags(of:)``
- ``Swift/Error/trace``
- ``Swift/Error/userLevel``
