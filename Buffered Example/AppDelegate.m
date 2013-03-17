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
    _updatesContent = [NSArrayController new];
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
    } else {
        [self performSelectorOnMainThread:@selector(loadProfiles) withObject:nil waitUntilDone:NO];
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
                [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

- (void) updateTable {
    NSMutableArray *newContent = [NSMutableArray new];
    for (NSDictionary *profile in self.profiles.arrangedObjects) {
        NSString *profiledId = [profile objectForKey:@"id"];
        [newContent addObject:profile];
        NSArray *updates = [self.updates objectForKey:profiledId];
        [newContent addObjectsFromArray:updates];
    }
    self.updatesContent.content = newContent;
    [self.updatesTable reloadData];
}

- (NSDictionary *) entityForRow: (NSInteger) row {
    return [self.updatesContent.arrangedObjects objectAtIndex:row];
}

- (BOOL) isProfileEntity: (NSDictionary *) dict {
    return [dict objectForKey:@"avatar"] != nil;
}

#pragma mark NSTableView
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary *entity = [self entityForRow:row];
    if (entity) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"Update" owner:self];
        return cell;
    } else {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"Profile" owner:self];
        return cell;
    }
}

// We want to make "group rows" for the folders
- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    return [self isProfileEntity:[self entityForRow:row]];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 110;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.updatesContent.arrangedObjects count];
}
#pragma mark -
@end
