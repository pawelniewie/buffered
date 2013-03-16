//
//  AppDelegate.m
//  Buffered Example
//
//  Created by Pawel Niewiadomski on 05.03.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import <Buffered/Buffered.h>
#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _profiles = [NSArrayController new];
    _updates = [NSMutableDictionary new];
    _buffered = [[Buffered alloc] initApplication:@"Buffered" withId:@"51366c442c4f4e6b02000006" andSecret:@"08a2b9d7c1c2dcc2f17f04d1caf3604b"];
    
    if (![_buffered isSignedIn:YES]) {
        [_buffered signInSheetModalForWindow:self.window withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                [self reportError:error];
            } else {
                [self performSelectorOnMainThread:@selector(loadProfiles) withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

- (void) loadProfiles {
    [self.progress startAnimation:self];

    [_buffered profiles:^(NSArray *profiles, NSError *error) {
        if (profiles != nil) {
            [self performSelectorOnMainThread:@selector(updateProfiles:) withObject:profiles waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:NO];
        }
    }];
}

- (void) reportError: (NSError *) error {
    NSLog(@"Error %@", error);
}

- (void) updateProfiles: (NSArray *) profiles {
    [self.profiles setContent:profiles];
    for (NSDictionary *profile in profiles) {
        __block NSString * profileId = [profile objectForKey:@"id"];
        [self.buffered pendingUpdatesForProfile:profileId withCompletionHandler:^(NSArray *pending, NSError *error) {
            if (pending != nil) {
                [self.updates setObject:pending forKey:profileId];
                [self performSelectorOnMainThread:@selector(updateTable:) withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

- (void) updateTable {
    [self.updatesTable reloadData];
}

#pragma mark NSTableView

#pragma mark -
@end
