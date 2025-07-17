#!/bin/bash

# Build FluffyDisplay without code signing for development
echo "Building FluffyDisplay..."
xcodebuild -project FluffyDisplay.xcodeproj -scheme FluffyDisplay build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

if [ $? -eq 0 ]; then
    echo "Build successful! Running FluffyDisplay..."
    open /Users/sliprub/Library/Developer/Xcode/DerivedData/FluffyDisplay-crsffxpkaivkhjfwxjkrpgxnvikx/Build/Products/Debug/FluffyDisplay.app
else
    echo "Build failed!"
    exit 1
fi
