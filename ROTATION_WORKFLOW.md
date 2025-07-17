# FluffyDisplay Rotation Workflow

This document explains how to properly use FluffyDisplay with rotated displays for sidecar setups.

## Understanding the Problem

When using FluffyDisplay with sidecar, you may encounter issues where:
- A rotated virtual display appears as a narrow strip on the sidecar device
- The content is squeezed into the middle third of the screen
- The rotation doesn't work as expected

## The Solution: Rotate at Source

**Key insight**: Rotation must happen at the **source** (bare metal Mac), not at the **destination** (FluffyDisplay).

### Correct Workflow

1. **Prepare the source display** (bare metal Mac):
   ```bash
   # Rotate the physical display to desired orientation
   displayplacer "id:<display-id> degree:90"
   ```

2. **Connect via sidecar**:
   - Use sidecar to connect the rotated display to your target device
   - The sidecar will now show the properly rotated content

3. **Mirror to FluffyDisplay**:
   - Create a FluffyDisplay virtual display with matching dimensions
   - Mirror the sidecar display to the FluffyDisplay virtual display
   - The rotation will be preserved through the mirroring process

### Example Commands

```bash
# 1. Find your display ID
displayplacer list

# 2. Rotate the source display (example: 90 degrees)
displayplacer "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 degree:90"

# 3. Connect via sidecar (done through macOS UI)

# 4. Create matching FluffyDisplay virtual display
# Use FluffyDisplay menu -> New -> [matching resolution]
```

## Menu Organization

The FluffyDisplay menu includes rotation options for organizational purposes:
- **Standard**: 0° rotation
- **90° Clockwise**: 90° rotation  
- **180°**: 180° rotation
- **270° Clockwise**: 270° rotation

These menu items help you:
- Quickly identify the intended rotation
- Organize virtual displays by rotation angle
- Plan your sidecar setup workflow

## Technical Details

- **Virtual Display Creation**: Always creates displays with exact specified dimensions
- **No Dimension Swapping**: FluffyDisplay doesn't swap width/height internally
- **Rotation Parameter**: Kept for menu organization and future enhancements
- **Source Rotation**: All actual rotation happens at the source using `displayplacer`

## Troubleshooting

### Display appears as narrow strip
- **Cause**: Rotation not applied at source
- **Solution**: Run `displayplacer` rotation command on bare metal Mac first

### Content is squeezed
- **Cause**: Dimension mismatch between source and destination
- **Solution**: Ensure FluffyDisplay virtual display matches rotated source dimensions

### Rotation not working
- **Cause**: Trying to rotate at FluffyDisplay level
- **Solution**: Apply rotation at source (bare metal Mac) before sidecaring

## Build Instructions

```bash
# Build and run FluffyDisplay
./build_and_run.sh

# Or manual build without code signing
xcodebuild -project FluffyDisplay.xcodeproj -scheme FluffyDisplay build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO
```

## Requirements

- macOS 10.15 or later
- Xcode development tools
- `displayplacer` utility (for source rotation)
- Physical Mac with external display (for source rotation)
