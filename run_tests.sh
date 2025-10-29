#!/usr/bin/env bash
set -euo pipefail

cd /workspace

echo "==> Running tests..."
./gradlew --no-daemon --offline :app:testDebugUnitTest