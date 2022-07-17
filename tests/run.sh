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

clang tests/main_with_macro.m -c -o tests/force_const.o -I . -arch x86_64 -DDUPCLASS_FORCE_DATA_CONST
output=$(size -m tests/force_const.o)
if [[ "$output" != *"__DATA_CONST, __objc_dupclass"* ]]; then
  echo "error: missing __DATA_CONST version" >&2
  exit 1
fi

clang tests/main_with_macro.m -c -o tests/force_data.o -I . -arch arm64 -DDUPCLASS_FORCE_DATA
output=$(size -m tests/force_data.o)
if [[ "$output" != *"__DATA, __objc_dupclass"* ]]; then
  echo "error: missing __DATA version" >&2
  exit 1
fi
