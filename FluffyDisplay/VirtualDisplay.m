// -*- Mode: ObjC; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4; fill-column: 100 -*-
//
// Modifications Copyright © 2025 sliprub
// Licensed under Apache License 2.0; see LICENSE for details.
//
// Original: FluffyDisplay by tml1024 (Apache 2.0)

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

#import "CGVirtualDisplay.h"
#import "CGVirtualDisplayDescriptor.h"
#import "CGVirtualDisplayMode.h"
#import "CGVirtualDisplaySettings.h"

#import "VirtualDisplay.h"

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
    // Handle rotation:
    // 0°/180°: width and height unchanged (180° image rotation needs to be handled during rendering)
    // 90°/270°: swap width and height
    int displayWidth = width;
    int displayHeight = height;
    if (rotation == 90 || rotation == 270) {
        displayWidth = height;
        displayHeight = width;
    }
    if (rotation == 180) {
        NSLog(@"[FluffyDisplay] 180-degree rotation requested: Output will be upside-down, but framebuffer image transform must be handled in the renderer if needed.");
        // Real 180° image rotation should be applied in the rendering logic if not handled by CoreGraphics
    }
    
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
