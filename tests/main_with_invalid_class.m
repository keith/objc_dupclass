#include "foo.h"
#include "objc_dupclass.h"

OBJC_DUPCLASS(Foo);
OBJC_DUPCLASS(Foo2);

int main() {
  NSLog(@"%@", [Foo new]);
  return 0;
}
