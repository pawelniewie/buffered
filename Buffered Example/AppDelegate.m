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

static NSString *DRAG_AND_DROP_TYPE = @"Update Data";

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
    
    [self.updatesTable registerForDraggedTypes:@[DRAG_AND_DROP_TYPE]];
    
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
    [self.progress stopAnimation:self];
    [self.progress setHidden:YES];
    [NSApp presentError:error];
}

- (void) updateProfiles: (NSArray *) profiles {
    [self.progress stopAnimation:self];
    [self.progress setHidden:YES];

    [self.profiles setContent:profiles];
    
    __block NSInteger counter = 0;
    for (Profile *profile in profiles) {
        __block NSString * profileId = profile.id;
        [self.buffered pendingUpdatesForProfile:profileId withCompletionHandler:^(NSArray *pending, NSError *error) {
            if (pending != nil) {
                NSMutableArray *copy = [NSMutableArray arrayWithArray:pending];
                [copy addObject:@{ @"text" : [NSString stringWithFormat:@"This is message %ld", (long)counter++] }];
                [copy addObject:@{ @"text" : [NSString stringWithFormat:@"This is message %ld", (long)counter++] }];
                [self.updates setObject:copy forKey:profileId];
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
        
        cell.textField.stringValue = [entity objectForKey:@"text"];
        
        return cell;
    } else {
        BUPendingTableCellView *cell = [tableView makeViewWithIdentifier:@"Profile" owner:self];
        Profile *profile = (Profile *) entity;
        
        cell.textField.stringValue = [profile.json objectForKey:@"formatted_username"];
        
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
    if ([self isProfileEntity:[self entityForRow:row]]) {
        return 50;
    } else {
        return 50;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.updatesContent.arrangedObjects count];
}
#pragma mark -
#pragma mark Drag and Drop
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    if ([rowIndexes indexPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return [self isProfileEntity:[self entityForRow:idx]];
    }] == NSNotFound) {
        // Copy the row numbers to the pasteboard.
        NSData *zNSIndexSetData = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
        [pboard declareTypes:[NSArray arrayWithObject:DRAG_AND_DROP_TYPE] owner:self];
        [pboard setData:zNSIndexSetData forType:DRAG_AND_DROP_TYPE];
        return YES;
    }
    return NO;
}

- (NSDragOperation)tableView:(NSTableView*)tv
                validateDrop:(id<NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)operation {

    if( [info draggingSource] == self.updatesTable ) {
		if( operation == NSTableViewDropOn ) {
			[tv setDropRow:row dropOperation:NSTableViewDropAbove];
        }
		return NSDragOperationMove;
	} else {
		return NSDragOperationNone;
	}
}

- (BOOL) tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    if (row < 0)
	{
		row = 0;
	}
    
    // if drag source is self, it's a move or copy
    if ([info draggingSource] == tableView)
    {
        NSPasteboard *pasteboard = [info draggingPasteboard];
        NSData *rowData = [pasteboard dataForType:DRAG_AND_DROP_TYPE];
        NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];

		[self moveObjectsInArrangedObjectsFromIndexes:rowIndexes toIndex:row];
            
        // set selected rows to those that were just moved
        // Need to work out what moved where to determine proper selection...
        NSInteger rowsAbove = [self rowsAboveRow:row inIndexSet:rowIndexes];
		
		NSRange range = NSMakeRange(row - rowsAbove, [rowIndexes count]);
		rowIndexes = [NSIndexSet indexSetWithIndexesInRange:range];
		[self.updatesContent setSelectionIndexes:rowIndexes];
		[self.updatesTable reloadData];
		return YES;
    }
	
    return NO;
}

- (NSUInteger)rowsAboveRow:(NSUInteger)row inIndexSet:(NSIndexSet *)indexSet
{
    NSUInteger currentIndex = [indexSet firstIndex];
    NSInteger i = 0;
    while (currentIndex != NSNotFound)
    {
		if (currentIndex < row) { i++; }
		currentIndex = [indexSet indexGreaterThanIndex:currentIndex];
    }
    return i;
}

-(void) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)indexSet toIndex:(NSUInteger)insertIndex
{
    NSArray	*objects = [self.updatesContent arrangedObjects];
	NSUInteger thisIndex = [indexSet lastIndex];
	
    NSInteger aboveInsertIndexCount = 0;
    id object;
    NSInteger removeIndex;
	
    while (NSNotFound != thisIndex)
	{
		if (thisIndex >= insertIndex)
		{
			removeIndex = thisIndex + aboveInsertIndexCount;
			aboveInsertIndexCount += 1;
		}
		else
		{
			removeIndex = thisIndex;
			insertIndex -= 1;
		}
		
		// Get the object we're moving
		object = [objects objectAtIndex:removeIndex];
        
		// In case nobody else is retaining the object, we need to keep it alive while we move it
		[self.updatesContent removeObjectAtArrangedObjectIndex:removeIndex];
		[self.updatesContent insertObject:object atArrangedObjectIndex:insertIndex];
		
		thisIndex = [indexSet indexLessThanIndex:thisIndex];
    }
}
#pragma mark -
@end
