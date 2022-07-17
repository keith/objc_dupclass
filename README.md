# objc_dupclass

Tired of:

```
objc[65171]: Class CDPCAReporter is implemented in both A.framework and B.framework. One of the two will be used. Which one is undefined.
```

Luckily, as I discovered from [this
tweet](https://twitter.com/_saagarjha/status/1509140471104241665), Apple
[added](https://github.com/apple-oss-distributions/objc4/commit/62b60ba0e56440e265ca576cc9f197e9af54c1bd#diff-510a2060e3422b44e197951716a1f6bb257728a9c61efd7ae0f8c16364212f89R174)
a special way to silence these warnings for classes you specify. This
repo provides a C macro for adding classes to this special location.

## Usage

For your own code, to silence the warning for the `Foo` class:

```objc
#import "objc_dupclass.h"

@interface Foo : NSObject
@end

// ...

OBJC_DUPCLASS(Foo);
```

For Apple's code, to silence the warning for classes you don't own:

```c
#include "objc_dupclass.h"

OBJC_DUPCLASS_FROM_STRING(AMSupportURLConnectionDelegate);
```
