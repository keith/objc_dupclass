#include <stdint.h>

// TODO: This isn't entirely accurate, but I'm not sure how to more accurately determine
#if (defined(__arm64__) || defined(DUPCLASS_FORCE_DATA_CONST)) && !defined(DUPCLASS_FORCE_DATA)
#define SECTION "__DATA_CONST"
#else
#define SECTION "__DATA"
#endif

#define OBJC_DUPCLASS(kclass) \
    __attribute__((used)) __attribute__((visibility("hidden"))) \
      static struct { uint32_t version; uint32_t flags; const char name[64]; } \
      const __duplicate_class_##kclass = { 0, 0, #kclass }; \
    \
    __attribute__((used)) __attribute__((visibility("hidden"))) \
      __attribute__((section (SECTION",__objc_dupclass"))) \
      const void* __set___objc_dupclass_sym___duplicate_class_##kclass = &__duplicate_class_##kclass
