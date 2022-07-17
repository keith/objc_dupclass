#include "foo.h"
#include "objc_dupclass.h"

OBJC_DUPCLASS(Foo);

int main() {
  NSLog(@"%@", [Foo new]);
  return 0;
}
