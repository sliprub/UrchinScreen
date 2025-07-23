# UrchinScreen

**A rotation-aware virtual display manager for macOS, enabling advanced multi-Mac Airplay workflows**

UrchinScreen is a fork of [FluffyDisplay](https://github.com/tml1024/FluffyDisplay) by tml1024, enhanced with rotation support and workflow automation for creating vertical display setups across multiple Macs.

## Attribution

- **Original Project**: [FluffyDisplay](https://github.com/tml1024/FluffyDisplay) by [tml1024](https://github.com/tml1024)
- **Original License**: Apache License 2.0
- **Fork Author**: [sliprub](https://github.com/sliprub)
- **Fork License**: Apache License 2.0 (inherited from original project)

## What is UrchinScreen?

UrchinScreen creates virtual displays on macOS with rotation support, designed specifically for a two-Mac workflow where you want to create a tall, vertical display setup using Airplay.

## Key Features

- **Virtual Display Creation**: Create virtual displays of any supported resolution
- **Rotation Support**: Create displays in Standard (0°), 90° Clockwise, 180°, or 270° Clockwise orientations
- **Multi-Mac Support**: Automatically discover and connect to other Macs running UrchinScreen
- **Airplay Integration**: Designed to work seamlessly with macOS Airplay for display mirroring

## The Two-Mac Vertical Display Workflow

This workflow creates a tall, vertical display using two Macs and Airplay:

### Requirements
- **Mac 1** (Main): Running UrchinScreen
- **Mac 2** (Airplay source): Physical Mac with rotatable display
- **displayplacer**: Install on Mac 2 via `brew install displayplacer`

### Setup Steps

1. **On Mac 1 (Main Mac with UrchinScreen)**:
   - Launch UrchinScreen
   - Click the menu bar icon
   - Go to "New" → Select your desired resolution → Choose "90° Clockwise"
   - This creates a virtual display with swapped dimensions (e.g., 1080×1920 instead of 1920×1080)

2. **On Mac 2 (90/270degree Mac)**:
   - Install displayplacer: `brew install displayplacer`
   - Run `displayplacer list` to identify your display
   - Rotate the physical display 90 degrees:
     ```bash
     displayplacer "id:<YOUR_DISPLAY_ID> res:1920x1080 rotation:90"
     ```
   - The physical display is now in portrait mode

3. **Connect via Airplay**:
   - On Mac 1, Airplay to Mac 2
   - Choose to mirror the UrchinScreen virtual display
   - Result: A tall, vertical display that spans the full height of the rotated physical screen

### Why This Works

- UrchinScreen creates a virtual display with pre-rotated dimensions (width/height swapped for 90°/270°)
- The physical Mac's display is rotated to match using displayplacer
- Airplay mirrors the virtual display to the rotated physical display
- The result is a seamless vertical display experience

## Installation

### From Release
1. Download the latest UrchinScreen.zip from [Releases](https://github.com/sliprub/UrchinScreen/releases)
2. Unzip and move UrchinScreen.app to your Applications folder
3. Launch UrchinScreen (you may need to right-click and select "Open" the first time)

### Building from Source
```bash
git clone https://github.com/sliprub/UrchinScreen.git
cd UrchinScreen
xcodebuild -scheme UrchinScreen build
```

Note: You'll need to configure code signing in Xcode for local builds.

## Security

UrchinScreen maintains the security model of the original FluffyDisplay:
- Fully sandboxed application
- Digitally signed and notarized
- Uses only necessary entitlements for virtual display creation

## Technical Details

### Changes from FluffyDisplay

1. **Rotation Support**: Added rotation parameter throughout the codebase
2. **Menu System**: Hierarchical menu structure for rotation options
3. **Display Creation**: Virtual displays handle dimension swapping for rotated orientations
4. **Documentation**: Comprehensive workflow documentation for the two-Mac setup

### API Usage

UrchinScreen uses undocumented CoreGraphics APIs (inherited from FluffyDisplay) and requires the `com.apple.security.temporary-exception.mach-lookup.global-name` entitlement.

## License

Copyright © 2025 sliprub

Based on FluffyDisplay, Copyright © 2024 tml1024

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Acknowledgments

Special thanks to:
- **tml1024** for creating the original FluffyDisplay and making it open source
- The macOS development community for documentation on undocumented APIs
- Contributors to displayplacer for enabling programmatic display rotation

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes with clear commit messages
4. Ensure all copyright headers are maintained
5. Submit a pull request

## Support

For issues, feature requests, or questions:
- Open an issue on [GitHub](https://github.com/sliprub/UrchinScreen/issues)
- Include your macOS version, hardware details, and steps to reproduce any issues
