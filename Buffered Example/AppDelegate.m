//
//  AppDelegate.m
//  Buffered Example
//
//  Created by Pawel Niewiadomski on 05.03.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import <Buffered/Buffered.h>
#import <Buffered/Model.h>
#import "AppDelegate.h"
#import "BUPendingTableCellView.h"

@implementation AppDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

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
    for (Profile *profile in profiles) {
        __block NSString * profileId = profile.id;
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
    for (Profile *profile in self.profiles.arrangedObjects) {
        [newContent addObject:profile];
        NSArray *updates = [self.updates objectForKey:profile.id];
        [newContent addObjectsFromArray:updates];
    }
    self.updatesContent.content = newContent;
    [self.updatesTable reloadData];
}

- (NSDictionary *) entityForRow: (NSInteger) row {
    return [self.updatesContent.arrangedObjects objectAtIndex:row];
}

- (Profile *)profileEntityForRow:(NSInteger)row {
    id result = row != -1 ? [self.updatesContent.arrangedObjects objectAtIndex:row] : nil;
    return [self isProfileEntity: result] ? result : nil;
}

- (BOOL) isProfileEntity: (NSObject *) object {
    return [object isKindOfClass:[Profile class]];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"avatarImage"]) {
        // Find the row and reload it.
        // Note that KVO notifications may be sent from a background thread (in this case, we know they will be)
        // We should only update the UI on the main thread, and in addition, we use NSRunLoopCommonModes to make sure the UI updates when a modal window is up.
        [self performSelectorOnMainThread:@selector(_reloadRowForEntity:) withObject:object waitUntilDone:NO modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
}
#pragma mark -
#pragma mark NSTableView
//- (void)tableView:(NSTableView *)tableView didRemoveRowView:(ATObjectTableRowView *)rowView forRow:(NSInteger)row {
    // Stop observing visible things
//    ATDesktopImageEntity *imageEntity = rowView.objectValue;
//    NSInteger index = imageEntity ? [_observedVisibleItems indexOfObject:imageEntity] : NSNotFound;
//    if (index != NSNotFound) {
//        [imageEntity removeObserver:self forKeyPath:ATEntityPropertyNamedThumbnailImage];
//        [_observedVisibleItems removeObjectAtIndex:index];
//    }
//}

- (void)_reloadRowForEntity:(id)object {
    NSInteger row = [self.updatesContent.arrangedObjects indexOfObject:object];
    if (row != NSNotFound) {
        Profile *entity = [self profileEntityForRow:row];
        BUPendingTableCellView *cellView = [self.updatesTable viewAtColumn:0 row:row makeIfNecessary:NO];
        if (cellView) {
            // Fade the imageView in, and fade the progress indicator out
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:0.8];
            [cellView.imageView setAlphaValue:0];
            cellView.imageView.image = entity.avatarImage;
            [cellView.imageView setHidden:NO];
            [[cellView.imageView animator] setAlphaValue:1.0];
            [cellView.progressIndicator setHidden:YES];
            [NSAnimationContext endGrouping];
        }
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary *entity = [self entityForRow:row];
    if (![self isProfileEntity:entity]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"Update" owner:self];
        return cell;
    } else {
        BUPendingTableCellView *cell = [tableView makeViewWithIdentifier:@"Profile" owner:self];
        Profile *profile = (Profile *) entity;
        
        // Use KVO to observe for changes of the thumbnail image
        if (_observedVisibleItems == nil) {
            _observedVisibleItems = [NSMutableArray new];
        }
        if (![_observedVisibleItems containsObject:entity]) {
            [profile addObserver:self forKeyPath:@"avatarImage" options:0 context:NULL];
            [profile loadAvatar];
            [_observedVisibleItems addObject:entity];
        }
        
        // Hide/show progress based on the thumbnail image being loaded or not.
        if (profile.avatarImage == nil) {
            [cell.progressIndicator setHidden:NO];
            [cell.progressIndicator startAnimation:nil];
            [cell.imageView setHidden:YES];
        } else {
            [cell.imageView setImage:profile.avatarImage];
        }

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
