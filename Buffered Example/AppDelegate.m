//
//  AppDelegate.m
//  Buffered Example
//
//  Created by Pawel Niewiadomski on 05.03.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import <Buffered/Buffered.h>
#import <Buffered/Model.h>
#import <Buffered/BUPendingUpdatesViewController.h>

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
    [[_pendingUpdatesViewController view] setFrame:[_pendingUpdates frame]];
    [self.window.contentView replaceSubview:_pendingUpdates with:_pendingUpdatesViewController.view];
}

-(NSArray*) makeView: (NSView*) _subView fullSizeAs: (NSView*) destination {
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:destination attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_subView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:destination attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_subView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:destination attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_subView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:destination attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    return @[top, bottom, left, right];
}

@end
