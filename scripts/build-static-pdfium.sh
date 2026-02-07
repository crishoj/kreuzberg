#!/usr/bin/env bash
# Build static libpdfium.a for Linux x86_64 musl using bblanchon/pdfium-binaries infrastructure.
# Output: ./pdfium-static/lib/libpdfium.a + ./pdfium-static/include/
#
# Requirements: Docker with --platform linux/amd64 support
# Disk: ~15GB during build, ~200MB output
# Time: ~20-40 minutes (mostly gclient sync + ninja)
set -euo pipefail

PDFIUM_BRANCH="${PDFIUM_BRANCH:-chromium/7665}"
OUTPUT_DIR="${1:-$PWD/pdfium-static}"

echo "==> Building static PDFium ($PDFIUM_BRANCH) for linux-musl-x64"
echo "==> Output: $OUTPUT_DIR"

docker build --platform linux/amd64 -t pdfium-static-builder -f - . <<'DOCKERFILE'
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    git curl python3 pkg-config g++ cmake lsb-release sudo patch file \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# depot_tools (GN + ninja + gclient)
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH="/build/depot_tools:${PATH}"

# musl cross-compiler
RUN curl -fsSL https://musl.cc/x86_64-linux-musl-cross.tgz | tar xz -C /build
ENV PATH="/build/x86_64-linux-musl-cross/bin:${PATH}"

# Clone bblanchon/pdfium-binaries for patches
RUN git clone --depth=1 https://github.com/bblanchon/pdfium-binaries.git /build/pdfium-binaries

# Checkout PDFium
ARG PDFIUM_BRANCH=chromium/7665
RUN gclient config --unmanaged https://pdfium.googlesource.com/pdfium.git \
      --custom-var "checkout_configuration=small" \
    && echo "target_os = [ 'linux' ]" >> .gclient \
    && gclient sync -r "origin/${PDFIUM_BRANCH}" --no-history --shallow

# Install build deps + sysroot (required by chromium build system)
RUN cd pdfium && build/install-build-deps.sh && gclient runhooks && build/linux/sysroot_scripts/install-sysroot.py --arch=x64

# Apply bblanchon musl patches (critical: sets up musl cross-compiler toolchain for GN)
RUN cd pdfium && patch -p1 -i /build/pdfium-binaries/patches/musl/pdfium.patch
RUN cd pdfium/build && patch -p1 -i /build/pdfium-binaries/patches/musl/build.patch
RUN mkdir -p pdfium/build/toolchain/linux/musl \
    && cp /build/pdfium-binaries/patches/musl/toolchain.gn pdfium/build/toolchain/linux/musl/BUILD.gn

# Apply public headers patch (needed for the pdfium-render crate)
RUN cd pdfium && patch -p1 -i /build/pdfium-binaries/patches/public_headers.patch

# Configure: static musl build
RUN mkdir -p pdfium/out && cat > pdfium/out/args.gn <<'GN'
clang_use_chrome_plugins = false
is_clang = false
is_component_build = false
is_debug = false
is_musl = true
pdf_enable_v8 = false
pdf_enable_xfa = false
pdf_is_complete_lib = true
pdf_is_standalone = true
pdf_use_partition_alloc = false
target_cpu = "x64"
target_os = "linux"
treat_warnings_as_errors = false
use_custom_libcxx = false
use_custom_libcxx_for_host = false
GN

RUN cd pdfium && gn gen out

# Build
RUN ninja -C pdfium/out pdfium

# Stage output
RUN mkdir -p /output/lib /output/include \
    && cp pdfium/out/obj/libpdfium.a /output/lib/ \
    && cp -r pdfium/public/* /output/include/ \
    && rm -f /output/include/DEPS /output/include/README /output/include/PRESUBMIT.py
DOCKERFILE

echo "==> Extracting libpdfium.a to $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Extract from Docker image
CONTAINER_ID=$(docker create --platform linux/amd64 pdfium-static-builder)
docker cp "$CONTAINER_ID:/output/." "$OUTPUT_DIR/"
docker rm "$CONTAINER_ID"

echo "==> Done!"
ls -lh "$OUTPUT_DIR/lib/libpdfium.a"
echo "==> Use with: PDFIUM_STATIC_LIB_PATH=$OUTPUT_DIR/lib cargo build ..."
