// -*- Mode: ObjC; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4; fill-column: 100 -*-

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
    
    // Create the virtual display with the requested dimensions (no swapping)
    // The rotation will be handled by displayplacer after creation
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

    // If rotation is requested, use displayplacer to rotate the display
    if (rotation != 0) {
        // Give the display a moment to be recognized by the system
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"Attempting to rotate display '%@' to %d degrees", name, rotation);
            
            // First, find the display ID
            NSTask *listTask = [[NSTask alloc] init];
            listTask.launchPath = @"/opt/homebrew/bin/displayplacer";
            listTask.arguments = @[@"list"];
            
            NSPipe *listPipe = [NSPipe pipe];
            listTask.standardOutput = listPipe;
            listTask.standardError = listPipe;
            
            [listTask launch];
            [listTask waitUntilExit];
            
            NSData *listData = [[listPipe fileHandleForReading] readDataToEndOfFile];
            NSString *listOutput = [[NSString alloc] initWithData:listData encoding:NSUTF8StringEncoding];
            
            // Parse the output to find our display
            NSArray *lines = [listOutput componentsSeparatedByString:@"\n"];
            NSString *displayId = nil;
            
            for (NSInteger i = 0; i < lines.count; i++) {
                NSString *line = [lines objectAtIndex:i];
                if ([line containsString:name]) {
                    // Look for the persistent screen id in the previous lines
                    for (NSInteger j = i - 1; j >= 0; j--) {
                        NSString *prevLine = [lines objectAtIndex:j];
                        if ([prevLine containsString:@"Persistent screen id:"]) {
                            NSArray *components = [prevLine componentsSeparatedByString:@" "];
                            if (components.count >= 4) {
                                displayId = [components objectAtIndex:3];
                                break;
                            }
                        }
                    }
                    break;
                }
            }
            
            if (displayId) {
                NSLog(@"Found display ID '%@' for display '%@', rotating to %d degrees", displayId, name, rotation);
                
                // Now rotate the display
                NSTask *rotateTask = [[NSTask alloc] init];
                rotateTask.launchPath = @"/opt/homebrew/bin/displayplacer";
                rotateTask.arguments = @[[NSString stringWithFormat:@"id:%@ degree:%d", displayId, rotation]];
                
                NSPipe *rotatePipe = [NSPipe pipe];
                rotateTask.standardOutput = rotatePipe;
                rotateTask.standardError = rotatePipe;
                
                [rotateTask launch];
                [rotateTask waitUntilExit];
                
                NSData *rotateData = [[rotatePipe fileHandleForReading] readDataToEndOfFile];
                NSString *rotateOutput = [[NSString alloc] initWithData:rotateData encoding:NSUTF8StringEncoding];
                
                NSLog(@"Rotation command completed. Output: %@", rotateOutput);
                
                if (rotateTask.terminationStatus == 0) {
                    NSLog(@"Successfully rotated display '%@' to %d degrees", name, rotation);
                } else {
                    NSLog(@"Failed to rotate display '%@'. Exit code: %d", name, rotateTask.terminationStatus);
                }
            } else {
                NSLog(@"Could not find display ID for display '%@'", name);
                NSLog(@"Available displays:\n%@", listOutput);
            }
        });
    }

    return display;
}
