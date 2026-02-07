#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-${TARGET:-}}"
if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 <target>" >&2
  exit 1
fi

if [[ "$TARGET" == *"musl"* ]]; then
  # musl: use static PDFium FFI (no dlopen) instead of bundled dynamic library
  cargo build --release --target "$TARGET" --package kreuzberg-cli \
    --no-default-features --features pdfium-static-ffi
else
  cargo build --release --target "$TARGET" --package kreuzberg-cli
fi
