//
//  AppDelegate.m
//  Buffered Example
//
//  Created by Pawel Niewiadomski on 05.03.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import <Buffered/Buffered.h>
#import <Buffered/Model.h>
#import "BUPendingUpdatesViewController.h"

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
    _buffered = [[Buffered alloc] initApplication:@"Buffered" withId:@"51366c442c4f4e6b02000006" andSecret:@"08a2b9d7c1c2dcc2f17f04d1caf3604b"];
    _pendingUpdatesViewController = [[BUPendingUpdatesViewController alloc] initWithBuffered:_buffered];
    
    [_pendingUpdatesViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_pendingUpdates addSubview:_pendingUpdatesViewController.view];
    
    NSDictionary *views = @{@"view" : _pendingUpdatesViewController.view};
    [_pendingUpdates addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:views]];
    [_pendingUpdates addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views]];
}

@end
