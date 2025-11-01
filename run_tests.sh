#!/usr/bin/env bash
# run_tests.sh - Script to validate the codebase and generate APKs
#
# This script runs inside the Docker container and does three things:
# 1. Runs unit tests (if any exist)
# 2. Builds the debug APK
# 3. Builds the instrumented test APK
#
# All tasks run offline using cached dependencies from the Docker build.

set -euo pipefail

cd /workspace

echo "==> Running unit tests..."
# Runs JVM-based unit tests (Robolectric, JUnit, etc.)
# Change module name if not using 'app'
./gradlew testDebugUnitTest --no-daemon --offline

echo ""
echo "==> Building debug APK..."
# Builds the main application APK
./gradlew assembleDebug --no-daemon --offline

echo ""
echo "==> Building test APK..."
# Builds the instrumented test APK
./gradlew assembleDebugAndroidTest --no-daemon --offline

echo ""
echo "==> ✅ Build complete! APK locations:"

# Dynamically find the APKs
DEBUG_APK=$(find app -name "*-debug.apk" -not -path "*/androidTest/*" 2>/dev/null | head -n 1)
TEST_APK=$(find app -name "*-debug-androidTest.apk" 2>/dev/null | head -n 1)

if [ -n "$DEBUG_APK" ]; then
    echo "Debug APK: $DEBUG_APK"
else
    echo "Debug APK: Not found (check build output)"
fi

if [ -n "$TEST_APK" ]; then
    echo "Test APK: $TEST_APK"
else
    echo "Test APK: Not found (check build output)"
fi

echo ""
echo "==> To run instrumented tests on an emulator:"
echo "1. Install both APKs on your emulator"
echo "2. Run: adb shell am instrument -w YOUR_PACKAGE.test/androidx.test.runner.AndroidJUnitRunner"
echo "   (Replace YOUR_PACKAGE with your applicationId from build.gradle.kts)"