#!/bin/bash

# Realms Version Bump Script
# Usage: ./bump_version.sh [major|minor|patch|build]

set -e

PROJECT_FILE="project.yml"
CURRENT_VERSION=$(grep "MARKETING_VERSION:" $PROJECT_FILE | sed 's/.*MARKETING_VERSION: //')

echo "Current version: $CURRENT_VERSION"

if [ -z "$1" ]; then
    echo "Usage: $0 [major|minor|patch|build]"
    echo "  major: 1.0.0 → 2.0.0"
    echo "  minor: 1.0.0 → 1.1.0"
    echo "  patch: 1.0.0 → 1.0.1"
    echo "  build: Increment build number only"
    exit 1
fi

case $1 in
    "major")
        # Parse current version
        IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
        MAJOR=$((${VERSION_PARTS[0]} + 1))
        NEW_VERSION="$MAJOR.0.0"
        echo "Bumping major version: $CURRENT_VERSION → $NEW_VERSION"
        ;;
    "minor")
        IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
        MAJOR=${VERSION_PARTS[0]}
        MINOR=$((${VERSION_PARTS[1]} + 1))
        NEW_VERSION="$MAJOR.$MINOR.0"
        echo "Bumping minor version: $CURRENT_VERSION → $NEW_VERSION"
        ;;
    "patch")
        IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
        MAJOR=${VERSION_PARTS[0]}
        MINOR=${VERSION_PARTS[1]}
        PATCH=$((${VERSION_PARTS[2]} + 1))
        NEW_VERSION="$MAJOR.$MINOR.$PATCH"
        echo "Bumping patch version: $CURRENT_VERSION → $NEW_VERSION"
        ;;
    "build")
        # Only increment build number
        NEW_VERSION=$CURRENT_VERSION
        echo "Keeping version: $NEW_VERSION"
        ;;
    *)
        echo "Invalid option: $1"
        exit 1
        ;;
esac

# Update project.yml
sed -i '' "s/MARKETING_VERSION: $CURRENT_VERSION/MARKETING_VERSION: $NEW_VERSION/g" $PROJECT_FILE

# Increment build number if requested
if [ "$1" = "build" ]; then
    CURRENT_BUILD=$(grep "CURRENT_PROJECT_VERSION:" $PROJECT_FILE | sed 's/.*CURRENT_PROJECT_VERSION: //')
    NEW_BUILD=$(($CURRENT_BUILD + 1))
    sed -i '' "s/CURRENT_PROJECT_VERSION: $CURRENT_BUILD/CURRENT_PROJECT_VERSION: $NEW_BUILD/g" $PROJECT_FILE
    echo "Build number incremented: $CURRENT_BUILD → $NEW_BUILD"
fi

echo "✅ Version updated successfully!"
echo "📱 New version: $NEW_VERSION"

# Regenerate project
echo "🔄 Regenerating Xcode project..."
xcodegen

echo "🎉 Done! You can now build your app with version $NEW_VERSION"
