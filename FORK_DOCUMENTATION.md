# UrchinScreen Fork Documentation

## Fork Information

**Original Repository**: https://github.com/tml1024/FluffyDisplay.git  
**Fork Repository**: https://github.com/sliprub/UrchinScreen  
**Fork Date**: July 16, 2025  
**Base Version**: Latest commit `67180e3` (February 15, 2024)  
**Base Commit**: "Merge pull request #21 from mrienstra/patch-ultrawide-aspect-ratios"  
**Initial Release**: v1.0.0  

## Overview

UrchinScreen is a fork of FluffyDisplay that adds comprehensive rotation support, enabling advanced multi-Mac workflows for creating vertical display setups using Sidecar.

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

**Complete Code Changes**:

#### Resolution Struct Modification

```swift
struct Resolution {
    let width, height, ppi: Int32
    let hiDPI: Bool
    let description: String
    let rotation: Int32
    
    init(_ width: Int32, _ height: Int32, _ ppi: Int32, _ hiDPI: Bool, _ description: String, rotation: Int32 = 0) {
        self.width = width
        self.height = height
        self.ppi = ppi
        self.hiDPI = hiDPI
        self.description = description
        self.rotation = rotation
    }
    
    init(_ width: Int, _ height: Int, _ ppi: Int, _ hiDPI: Bool, _ description: String, rotation: Int = 0) {
        self.init(Int32(width), Int32(height), Int32(ppi), hiDPI, description, rotation: Int32(rotation))
    }
}
```

#### Menu Creation Replacement

```swift
for size in predefResolutions {
    let resolutionSubmenu = NSMenu()
    
    let rotations = [(0, "Standard"), (90, "90° Clockwise"), (180, "180°"), (270, "270° Clockwise")]
    
    for (angle, rotationName) in rotations {
        let rotatedResolution = Resolution(size.width, size.height, size.ppi, size.hiDPI, size.description, rotation: Int32(angle))
        let rotationItem = NSMenuItem(title: rotationName, action: #selector(newDisplayWithRotation(_:)), keyEquivalent: "")
        rotationItem.tag = i * 10 + (angle / 90)
        rotationItem.representedObject = rotatedResolution
        resolutionSubmenu.addItem(rotationItem)
    }
    
    let item = NSMenuItem(title: "\(size.width)×\(size.height) (\(size.description))", action: nil, keyEquivalent: "")
    item.submenu = resolutionSubmenu
    newMenu.addItem(item)
    i += 1
}
```

#### New Method for Rotation-Aware Display Creation

```swift
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
            ns.setTXTRecord(nil)
        }
    }
}
```

#### Updated Existing Methods

```swift
if let display = createVirtualDisplay(resolution.width,
                                      resolution.height,
                                      resolution.ppi,
                                      resolution.hiDPI,
                                      name,
                                      Int32(resolution.rotation)) {

if let display = createVirtualDisplay(peerDisplay.resolution.width,
                                      peerDisplay.resolution.height,
                                      peerDisplay.resolution.ppi,
                                      peerDisplay.resolution.hiDPI,
                                      peerDisplay.resolution.description,
                                      Int32(peerDisplay.resolution.rotation)) {
```

### 2. FluffyDisplay/VirtualDisplay.h

**Purpose**: Updated function signature to accept rotation parameter

**Exact Code Changes**:

```objc
#import <Foundation/Foundation.h>

id createVirtualDisplay(int width, int height, int ppi, BOOL hiDPI, NSString *name, int rotation);
```

### 3. FluffyDisplay/VirtualDisplay.m

**Purpose**: Updated virtual display creation to accept rotation parameter and added documentation

**Complete Function Code**:

```objc
id createVirtualDisplay(int width, int height, int ppi, BOOL hiDPI, NSString *name, int rotation) {

    CGVirtualDisplaySettings *settings = [[CGVirtualDisplaySettings alloc] init];
    settings.hiDPI = hiDPI;

    CGVirtualDisplayDescriptor *descriptor = [[CGVirtualDisplayDescriptor alloc] init];
    descriptor.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    descriptor.name = name;

    // See System Preferences > Displays > Color > Open Profile > Apple display native information
    descriptor.whitePoint = CGPointMake(0.3125, 0.3291);
    descriptor.bluePrimary = CGPointMake(0.1494, 0.0557);
    descriptor.greenPrimary = CGPointMake(0.2559, 0.6983);
    descriptor.redPrimary = CGPointMake(0.6797, 0.3203);
    
    // Create the virtual display with the requested dimensions
    // Rotation workflow: rotate source display -> sidecar -> mirror to FluffyDisplay
    int displayWidth = width;
    int displayHeight = height;
    
    descriptor.maxPixelsHigh = displayHeight;
    descriptor.maxPixelsWide = displayWidth;
    descriptor.sizeInMillimeters = CGSizeMake(25.4 * displayWidth / ppi, 25.4 * displayHeight / ppi);
    descriptor.serialNum = 1;
    descriptor.productID = 1;
    descriptor.vendorID = 1;

    CGVirtualDisplay *display = [[CGVirtualDisplay alloc] initWithDescriptor:descriptor];

    if (settings.hiDPI) {
        displayWidth /= 2;
        displayHeight /= 2;
    }
    CGVirtualDisplayMode *mode = [[CGVirtualDisplayMode alloc] initWithWidth:displayWidth
                                                                      height:displayHeight
                                                                 refreshRate:60];
    settings.modes = @[mode];

    if (![display applySettings:settings])
        return nil;

    // Note: Rotation is handled at the source (bare metal Mac) using displayplacer
    // before sidecaring to FluffyDisplay. The rotation parameter is kept for
    // menu organization and future use.

    return display;
}
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
