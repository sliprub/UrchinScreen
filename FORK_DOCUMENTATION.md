# FluffyDisplay Fork Documentation

## Fork Information

**Original Repository**: https://github.com/tml1024/FluffyDisplay.git  
**Fork Date**: July 16, 2025  
**Base Version**: Latest commit `67180e3` (February 15, 2024)  
**Base Commit**: "Merge pull request #21 from mrienstra/patch-ultrawide-aspect-ratios"  
**Branch**: `feature/rotation-support`  

## Overview

This fork adds comprehensive rotation support to FluffyDisplay, enabling better organization and workflow for sidecar setups with rotated displays.

## Changes Summary

- **5 files modified/added**
- **+197 lines added**
- **-16 lines removed**
- **Net change: +181 lines**

## Detailed Changes

### 1. FluffyDisplay/AppDelegate.swift

**Purpose**: Added rotation support to the menu system and virtual display creation

**Key Changes**:
- Added `rotation` property to `Resolution` struct
- Modified both `Resolution` initializers to accept rotation parameter
- Replaced flat menu with hierarchical rotation submenus
- Added `newDisplayWithRotation` method for rotation-aware display creation
- Updated display naming to include rotation information

**Code Changes**:

```swift
// ADDED: Rotation property to Resolution struct
struct Resolution {
    let width, height, ppi: Int32
    let hiDPI: Bool
    let description: String
    let rotation: Int32  // ← NEW
    
    // MODIFIED: Added rotation parameter with default value 0
    init(_ width: Int32, _ height: Int32, _ ppi: Int32, _ hiDPI: Bool, _ description: String, rotation: Int32 = 0) {
        self.width = width
        self.height = height
        self.ppi = ppi
        self.hiDPI = hiDPI
        self.description = description
        self.rotation = rotation  // ← NEW
    }
    
    // MODIFIED: Added rotation parameter with default value 0
    init(_ width: Int, _ height: Int, _ ppi: Int, _ hiDPI: Bool, _ description: String, rotation: Int = 0) {
        self.init(Int32(width), Int32(height), Int32(ppi), hiDPI, description, rotation: Int32(rotation))
    }
}
```

```swift
// REPLACED: Flat menu creation with hierarchical rotation submenus
// OLD CODE:
// let item = NSMenuItem(title: "\(size.width)×\(size.height) (\(size.description))", action: #selector(newDisplay(_:)), keyEquivalent: "")
// item.tag = i
// newMenu.addItem(item)

// NEW CODE:
for size in predefResolutions {
    // Create a submenu for each resolution with rotation options
    let resolutionSubmenu = NSMenu()
    
    // Add rotation options for this resolution
    let rotations = [(0, "Standard"), (90, "90° Clockwise"), (180, "180°"), (270, "270° Clockwise")]
    
    for (angle, rotationName) in rotations {
        let rotatedResolution = Resolution(size.width, size.height, size.ppi, size.hiDPI, size.description, rotation: Int32(angle))
        let rotationItem = NSMenuItem(title: rotationName, action: #selector(newDisplayWithRotation(_:)), keyEquivalent: "")
        rotationItem.tag = i * 10 + (angle / 90) // Encode resolution index and rotation
        rotationItem.representedObject = rotatedResolution
        resolutionSubmenu.addItem(rotationItem)
    }
    
    let item = NSMenuItem(title: "\(size.width)×\(size.height) (\(size.description))", action: nil, keyEquivalent: "")
    item.submenu = resolutionSubmenu
    newMenu.addItem(item)
    i += 1
}
```

```swift
// ADDED: New method for rotation-aware display creation
@objc func newDisplayWithRotation(_ sender: AnyObject?) {
    if let menuItem = sender as? NSMenuItem,
       let resolution = menuItem.representedObject as? Resolution {
        
        let rotationSuffix = resolution.rotation == 0 ? "" : " (\(resolution.rotation)°)"
        let name = "FluffyDisplay Virtual Display #\(virtualDisplayCounter)\(rotationSuffix)"
        
        if let display = createVirtualDisplay(resolution.width,
                                              resolution.height,
                                              resolution.ppi,
                                              resolution.hiDPI,
                                              name,
                                              Int32(resolution.rotation)) {
            
            virtualDisplays[virtualDisplayCounter] = VirtualDisplay(number: virtualDisplayCounter, display: display)
            
            let displayInfo = resolution.rotation == 0 ? 
                "\(resolution.width)×\(resolution.height)" : 
                "\(resolution.width)×\(resolution.height) (\(resolution.rotation)°)"
            
            let deleteItem = NSMenuItem(title: "\(name) (\(displayInfo))",
                                       action: #selector(deleteDisplay(_:)),
                                       keyEquivalent: "")
            deleteItem.tag = virtualDisplayCounter
            deleteMenu.addItem(deleteItem)
            deleteSubmenu.isHidden = false
            
            virtualDisplayCounter += 1
            
            // If we have created a new virtual display, this FluffyDisplay clearly is the
            // "main" Mac and no other Mac will use a physical display on this Mac. So we
            // don't need to advertise our displays.
            ns.setTXTRecord(nil)
        }
    }
}
```

```swift
// MODIFIED: Updated existing display creation methods to pass rotation parameter
// In newDisplay(_:)
if let display = createVirtualDisplay(resolution.width,
                                      resolution.height,
                                      resolution.ppi,
                                      resolution.hiDPI,
                                      name,
                                      Int32(resolution.rotation)) {  // ← ADDED rotation parameter

// In newAutoDisplay(_:)
if let display = createVirtualDisplay(peerDisplay.resolution.width,
                                      peerDisplay.resolution.height,
                                      peerDisplay.resolution.ppi,
                                      peerDisplay.resolution.hiDPI,
                                      peerDisplay.resolution.description,
                                      Int32(peerDisplay.resolution.rotation)) {  // ← ADDED rotation parameter
```

### 2. FluffyDisplay/VirtualDisplay.h

**Purpose**: Updated function signature to accept rotation parameter

**Code Changes**:

```objc
// MODIFIED: Added rotation parameter to function signature
// OLD:
// id createVirtualDisplay(int width, int height, int ppi, BOOL hiDPI, NSString *name);

// NEW:
id createVirtualDisplay(int width, int height, int ppi, BOOL hiDPI, NSString *name, int rotation);
```

### 3. FluffyDisplay/VirtualDisplay.m

**Purpose**: Updated virtual display creation to accept rotation parameter and added documentation

**Code Changes**:

```objc
// MODIFIED: Updated function signature and added rotation parameter
// OLD:
// id createVirtualDisplay(int width, int height, int ppi, BOOL hiDPI, NSString *name) {

// NEW:
id createVirtualDisplay(int width, int height, int ppi, BOOL hiDPI, NSString *name, int rotation) {
```

```objc
// MODIFIED: Improved variable naming and added workflow comments
// OLD:
// descriptor.maxPixelsHigh = height;
// descriptor.maxPixelsWide = width;
// descriptor.sizeInMillimeters = CGSizeMake(25.4 * width / ppi, 25.4 * height / ppi);

// NEW:
// Create the virtual display with the requested dimensions
// Rotation workflow: rotate source display -> sidecar -> mirror to FluffyDisplay
int displayWidth = width;
int displayHeight = height;

descriptor.maxPixelsHigh = displayHeight;
descriptor.maxPixelsWide = displayWidth;
descriptor.sizeInMillimeters = CGSizeMake(25.4 * displayWidth / ppi, 25.4 * displayHeight / ppi);
```

```objc
// MODIFIED: Updated hiDPI calculation to use new variable names
// OLD:
// if (settings.hiDPI) {
//     width /= 2;
//     height /= 2;
// }
// CGVirtualDisplayMode *mode = [[CGVirtualDisplayMode alloc] initWithWidth:width
//                                                                   height:height
//                                                              refreshRate:60];

// NEW:
if (settings.hiDPI) {
    displayWidth /= 2;
    displayHeight /= 2;
}
CGVirtualDisplayMode *mode = [[CGVirtualDisplayMode alloc] initWithWidth:displayWidth
                                                                  height:displayHeight
                                                             refreshRate:60];
```

```objc
// ADDED: Documentation comment explaining rotation workflow
// Note: Rotation is handled at the source (bare metal Mac) using displayplacer
// before sidecaring to FluffyDisplay. The rotation parameter is kept for
// menu organization and future use.
```

### 4. ROTATION_WORKFLOW.md (NEW FILE)

**Purpose**: Comprehensive documentation of the rotation workflow for sidecar setups

**Content**: 100-line documentation file explaining:
- The problem with rotated displays in sidecar setups
- Correct workflow (rotate at source, not destination)
- Example commands and usage
- Menu organization explanation
- Technical details
- Troubleshooting guide
- Build instructions
- Requirements

### 5. build_and_run.sh (NEW FILE)

**Purpose**: Automated build script for development without code signing

**Code**:

```bash
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
```

## Commit History

### Main Development Commits

1. **6ac2cc9** - "Add rotation support to FluffyDisplay"
   - Initial implementation with rotation menu and parameters

2. **31cddb2** - "Working rotation menu implementation - backup before sidecar rotation fix"
   - Backup commit with working rotation menu system

3. **4947101** - "Implement proper display rotation using displayplacer with improved error handling"
   - Added displayplacer integration (later removed)

4. **43d887d** - "Clean implementation: rotation menu for organization, actual rotation at source"
   - Removed unnecessary rotation logic, kept menu for organization

5. **be23a1a** - "Add comprehensive rotation workflow documentation"
   - Added complete documentation and build script

## Technical Details

### Rotation Workflow Understanding

The key insight discovered during development was that rotation should **not** happen at the FluffyDisplay level. Instead:

1. **Source rotation**: Use `displayplacer` to rotate the physical display on the bare metal Mac
2. **Sidecar connection**: Connect the rotated display via sidecar 
3. **Mirror to FluffyDisplay**: Mirror the rotated sidecar display to FluffyDisplay virtual display

### Menu Structure

The rotation menu creates a hierarchy:
```
Resolution (e.g., "1920×1080 (HD, 21.5-inch iMac)")
├── Standard (0°)
├── 90° Clockwise
├── 180°
└── 270° Clockwise
```

### Encoding System

Rotation options are encoded in menu item tags:
- `tag = resolution_index * 10 + rotation_step`
- `rotation_step = angle / 90` (0, 1, 2, 3)
- Examples: tag 15 = resolution index 1, 180° rotation

## Build Instructions

```bash
# Quick build and run
./build_and_run.sh

# Manual build without code signing
xcodebuild -project FluffyDisplay.xcodeproj -scheme FluffyDisplay build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

# Run manually
open /Users/sliprub/Library/Developer/Xcode/DerivedData/FluffyDisplay-crsffxpkaivkhjfwxjkrpgxnvikx/Build/Products/Debug/FluffyDisplay.app
```

## Requirements

- macOS 10.15 or later
- Xcode development tools
- `displayplacer` utility (for source rotation workflow)

## Usage

1. **For standard displays**: Use "Standard" rotation option
2. **For rotated sidecar setups**: 
   - First rotate source display with `displayplacer`
   - Then connect via sidecar
   - Finally mirror to FluffyDisplay virtual display
3. **Menu organization**: Use rotation options to identify intended display orientation

## Key Improvements

- **Better organization**: Hierarchical menu structure
- **Clear workflow**: Documented rotation process
- **Development friendly**: Automated build script
- **Comprehensive docs**: Full workflow and troubleshooting guide
- **Future-ready**: Rotation parameter available for future enhancements
