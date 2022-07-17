#!/bin/bash

set -euo pipefail
set -x

clang tests/foo.m -o tests/libfoo.dylib -dynamiclib -framework Foundation
clang tests/foo.m -c -o tests/foo.o
clang tests/empty_main.c -c -o tests/empty_main.o

ld \
  -arch "$(arch)" \
  -framework Foundation \
  -lfoo -Ltests \
  -lSystem \
  -syslibroot "$(xcrun --show-sdk-path)" \
  tests/empty_main.o tests/foo.o \
  -o tests/dupclass.bin

output=$(./tests/dupclass.bin 2>&1)
if [[ "$output" != *"Class Foo is implemented in both"* ]]; then
  echo "error: missing duplicate class warning: $output" >&2
  exit 1
fi

clang tests/main_with_macro.m -c -o tests/main_with_macro.o -I .
ld \
  -arch "$(arch)" \
  -framework Foundation \
  -lfoo -Ltests \
  -lSystem \
  -syslibroot "$(xcrun --show-sdk-path)" \
  tests/main_with_macro.o tests/foo.o \
  -o tests/nowarning.bin

output=$(./tests/nowarning.bin 2>&1)
if [[ "$output" == *"Class Foo is implemented in both"* ]]; then
  echo "error: had unexpected duplicate class warning: $output" >&2
  exit 1
elif [[ "$output" != *"<Foo: 0x"* ]]; then
  echo "error: missing expected output: $output" >&2
  exit 1
fi

if clang tests/main_with_invalid_class.m -c -o /dev/null -I . 2>/dev/null; then
  echo "error: main_with_invalid_class shouldn't have built" >&2
  exit 1
fi

clang tests/main_with_macro.m -c -o tests/main_with_macro.o -I .
ld \
  -arch "$(arch)" \
  -framework Foundation \
  -lfoo -Ltests \
  -lSystem \
  -syslibroot "$(xcrun --show-sdk-path)" \
  tests/main_with_macro.o tests/foo.o \
  -o tests/nowarning.bin
