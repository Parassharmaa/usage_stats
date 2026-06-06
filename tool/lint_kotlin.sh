#!/usr/bin/env bash
#
# Lint the Android Kotlin sources with ktlint (style) and detekt (static
# analysis). Install the tools with `brew install ktlint detekt` (or see
# https://pinterest.github.io/ktlint and https://detekt.dev).
set -euo pipefail

cd "$(dirname "$0")/.."
SRC="android/src/main/kotlin"

echo "==> ktlint"
ktlint "$SRC/**/*.kt"

echo "==> detekt"
detekt --input "$SRC" --config tool/detekt.yml --build-upon-default-config

echo "All Kotlin lint checks passed."
