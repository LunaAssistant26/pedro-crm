#!/bin/bash

# Walking Routes - Automated Build Script
# Usage: ./build-and-capture.sh [milestone-name]

PROJECT_NAME="WalkingRoutes"
SCHEME="WalkingRoutes"
DEVICE="iPhone 17"
OUTPUT_DIR="build-output"
MILESTONE=${1:-"milestone-$(date +%Y%m%d-%H%M%S)"}

echo "🏃‍♂️ Walking Routes - Build Automation"
echo "====================================="
echo "Milestone: $MILESTONE"
echo ""

# Create output directory
mkdir -p $OUTPUT_DIR/$MILESTONE

# Clean previous builds
echo "🧹 Cleaning previous builds..."
xcodebuild clean -project $PROJECT_NAME.xcodeproj -scheme $SCHEME

# Build for simulator
echo "🔨 Building for iOS Simulator..."
xcodebuild \
  -project $PROJECT_NAME.xcodeproj \
  -scheme $SCHEME \
  -destination "platform=iOS Simulator,name=$DEVICE" \
  -configuration Debug \
  build

if [ $? -ne 0 ]; then
  echo "❌ Build failed! Check logs above."
  exit 1
fi

echo "✅ Build successful!"
echo ""

# Boot simulator if not running
echo "📱 Ensuring simulator is ready..."
xcrun simctl boot "$DEVICE" 2>/dev/null || true

# Get app bundle path
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "$PROJECT_NAME.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
  echo "⚠️  Could not find built app bundle"
  exit 1
fi

echo "📦 App bundle: $APP_PATH"

# Install and launch app
echo "🚀 Installing app on simulator..."
xcrun simctl install booted "$APP_PATH"

# Wait for install
sleep 2

echo "▶️  Launching app..."
APP_BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw -o - "$APP_PATH/Info.plist")
xcrun simctl launch booted "$APP_BUNDLE_ID"

# Wait for app to fully load
sleep 5

echo ""
echo "📸 Capturing screenshots..."

# Take screenshots of key screens
xcrun simctl io booted screenshot "$OUTPUT_DIR/$MILESTONE/01-launch-screen.png"
echo "✓ Launch screen captured"

sleep 2

# Simulate tap to navigate (you'll need to customize these coordinates)
# xcrun simctl io booted tap 200 400
# sleep 1
# xcrun simctl io booted screenshot "$OUTPUT_DIR/$MILESTONE/02-route-list.png"
# echo "✓ Route list captured"

echo ""
echo "🎥 Recording demo video (10 seconds)..."
timeout 10 xcrun simctl io booted recordVideo "$OUTPUT_DIR/$MILESTONE/demo-walkthrough.mov" || true
echo "✓ Demo video captured"

echo ""
echo "📁 Output saved to: $OUTPUT_DIR/$MILESTONE/"
echo ""
echo "Files generated:"
ls -lh "$OUTPUT_DIR/$MILESTONE/"

echo ""
echo "🎉 Build complete! Share these files:"
echo "   - Screenshots: $OUTPUT_DIR/$MILESTONE/*.png"
echo "   - Demo video: $OUTPUT_DIR/$MILESTONE/*.mov"
