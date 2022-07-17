#!/bin/bash

set -euo pipefail

clang tests/foo.m -o tests/libfoo.dylib -dynamiclib -framework Foundation
clang tests/foo.m -c -o tests/foo.o
clang tests/empty_main.c -c -o tests/empty_main.o

ld \
  -arch "$(uname -m)" \
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
  -arch "$(uname -m)" \
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

clang tests/main_with_string_macro.c -c -o tests/main_with_string_macro.o -I .
ld \
  -arch "$(uname -m)" \
  -framework Foundation \
  -lfoo -Ltests \
  -lSystem \
  -syslibroot "$(xcrun --show-sdk-path)" \
  tests/main_with_string_macro.o tests/foo.o \
  -o tests/nowarningfromstring.bin

output=$(./tests/nowarningfromstring.bin 2>&1)
if [[ "$output" == *"Class Foo is implemented in both"* ]]; then
  echo "error: had unexpected duplicate class warning: $output" >&2
  exit 1
fi

clang tests/main_with_macro.m -c -o tests/main_with_macro.o -I .
ld \
  -arch "$(uname -m)" \
  -framework Foundation \
  -lfoo -Ltests \
  -lSystem \
  -syslibroot "$(xcrun --show-sdk-path)" \
  tests/main_with_macro.o tests/foo.o \
  -o tests/nodeadstrip.bin

output=$(nm -U tests/nodeadstrip.bin)
if [[ "$output" != *__deadstripped_shim* ]]; then
  echo "error: expected dead strip symbol without the argument" >&2
  exit 1
fi

clang tests/main_with_macro.m -c -o tests/main_with_macro.o -I .
ld \
  -arch "$(uname -m)" \
  -dead_strip \
  -framework Foundation \
  -lfoo -Ltests \
  -lSystem \
  -syslibroot "$(xcrun --show-sdk-path)" \
  tests/main_with_macro.o tests/foo.o \
  -o tests/withdeadstrip.bin

output=$(nm -U tests/withdeadstrip.bin)
if [[ "$output" == *__deadstripped_shim* ]]; then
  echo "error: unexpected dead strip symbol with the argument" >&2
  exit 1
fi
