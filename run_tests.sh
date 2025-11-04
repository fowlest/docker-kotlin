#!/usr/bin/env bash
# run_tests.sh - Script to validate the codebase and generate APKs
#
# ⚠️  IMPORTANT: Customize this script for your project! ⚠️
# Replace the placeholders below with your actual values.
#
# This script runs inside the Docker container and does three things:
# 1. Runs unit tests (if any exist)
# 2. Builds the debug APK
# 3. Builds the instrumented test APK
#
# All tasks run offline using cached dependencies from the Docker build.

set -euo pipefail

cd /workspace

# ============================================================================
# 🔧 CUSTOMIZE THESE VALUES FOR YOUR PROJECT
# ============================================================================
# To find these values:
#   MODULE_NAME: Look at your project structure (app/, main/, mobile/, etc.)
#   PACKAGE_NAME: Check your AndroidManifest.xml for the package attribute
#   MAIN_ACTIVITY: Usually "MainActivity" or check your manifest
# ============================================================================

MODULE_NAME="REPLACE_WITH_YOUR_MODULE"        # e.g., "app" or "main"
PACKAGE_NAME="REPLACE_WITH_YOUR_PACKAGE"      # e.g., "com.example.myapp"
MAIN_ACTIVITY="REPLACE_WITH_MAIN_ACTIVITY"    # e.g., "MainActivity"

# ============================================================================
# End of customization section
# ============================================================================

# Validate that placeholders were replaced
if [[ "$MODULE_NAME" == "REPLACE_WITH_YOUR_MODULE" ]] || \
   [[ "$PACKAGE_NAME" == "REPLACE_WITH_YOUR_PACKAGE" ]] || \
   [[ "$MAIN_ACTIVITY" == "REPLACE_WITH_MAIN_ACTIVITY" ]]; then
    echo "❌ ERROR: Please customize run_tests.sh before building!"
    echo "Edit the script and replace the REPLACE_WITH_* placeholders."
    exit 1
fi

echo "==> Running unit tests..."
./gradlew testDebugUnitTest --no-daemon --offline

echo ""
echo "==> Building debug APK..."
./gradlew assembleDebug --no-daemon --offline

echo ""
echo "==> Building test APK..."
./gradlew assembleDebugAndroidTest --no-daemon --offline

echo ""
echo "==> ✅ Build complete! APK locations:"

# Use the customized module name to find APKs
DEBUG_APK=$(find "$MODULE_NAME" -path "*/build/outputs/apk/debug/*.apk" -not -path "*/androidTest/*" 2>/dev/null | head -n 1)
TEST_APK=$(find "$MODULE_NAME" -path "*/build/outputs/apk/androidTest/debug/*-androidTest.apk" 2>/dev/null | head -n 1)

if [ -n "$DEBUG_APK" ]; then
    echo "Debug APK: $DEBUG_APK"
else
    echo "Debug APK: Not found in $MODULE_NAME/build/outputs/apk/debug/"
    echo "           (Check if module name is correct)"
fi

if [ -n "$TEST_APK" ]; then
    echo "Test APK: $TEST_APK"
else
    echo "Test APK: Not found in $MODULE_NAME/build/outputs/apk/androidTest/debug/"
fi

echo ""
echo "==> ADB Commands:"
echo "Launch app:"
echo "  adb shell am start -n ${PACKAGE_NAME}/.${MAIN_ACTIVITY}"
echo ""
echo "Run instrumented tests:"
echo "  adb shell am instrument -w ${PACKAGE_NAME}.test/androidx.test.runner.AndroidJUnitRunner"