#define OBJC_DUPCLASS(kclass) \
    __attribute__((visibility("hidden"))) \
      void __deadstripped_shim__##kclass() { (void)[kclass class]; } \
    \
    __attribute__((used)) __attribute__((visibility("hidden"))) \
      static struct { uint32_t version; uint32_t flags; const char name[64]; } \
      const __duplicate_class_##kclass = { 0, 0, #kclass }; \
    \
    __attribute__((used)) __attribute__((visibility("hidden"))) \
      __attribute__((section ("__DATA_CONST,__objc_dupclass"))) \
      const void* __set___objc_dupclass_sym___duplicate_class_##kclass = &__duplicate_class_##kclass;
