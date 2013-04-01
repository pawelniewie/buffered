//
//  AppDelegate.h
//  Buffered Example
//
//  Created by Pawel Niewiadomski on 05.03.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Buffered, BUPendingUpdatesViewController;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTabViewDelegate> {
@private
    NSMutableArray *_observedVisibleItems;
    UpdatesCompletionHandler _updatesHandler;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *pendingUpdates;

@property (strong) Buffered *buffered;
@property (strong) BUPendingUpdatesViewController *pendingUpdatesViewController;

@end
