#!/bin/zsh
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "🔨 Building circleOne..."
swift build -c debug

echo "📦 Updating circleOne.app bundle..."
mkdir -p circleOne.app/Contents/MacOS
mkdir -p circleOne.app/Contents/Resources
cp .build/debug/circleOne circleOne.app/Contents/MacOS/circleOne
cp -R circleOne/Resources/* circleOne.app/Contents/Resources/ 2>/dev/null || true

echo "🚀 Launching circleOne..."
open circleOne.app

echo "✅ circleOne is running!"
