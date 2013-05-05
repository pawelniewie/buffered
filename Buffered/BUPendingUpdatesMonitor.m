//
//  BUPendingUpdatesMonitor.m
//  Buffered
//
//  Created by Pawel Niewiadomski on 05.05.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import "Buffered.h"
#import "BUPendingUpdatesMonitor.h"

@implementation BUPendingUpdatesMonitor

- (id) initWithBuffered:(Buffered *)buffered andProfile: (Profile *) profile {
    self = [super initWithBuffered:buffered];
    if (self) {
        self.profileId = profile.id;
        _pendingUpdates = [NSMutableArray new];
    }
    return self;
}

- (void) refresh {
    self.inProgress = YES; // don't care if it's called twice, we just want to have some indicator it's in progress
    
    [self.buffered pendingUpdatesForProfile:self.profileId
          withCompletionHandler:^(NSString *profileId, NSArray *pending, NSError *error) {
              self.inProgress = NO;
              
              if (pending != nil) {
                  [self willChangeValueForKey:@"pendingUpdates"];
                  [_pendingUpdates removeAllObjects];
                  [_pendingUpdates addObjectsFromArray:pending];
                  [self didChangeValueForKey:@"pendingUpdates"];
              } else {
                  self.lastError = error;
                  if (self.delegate != nil) {
                      [self.delegate reportError:error];
                  }
              }
          }];
}

@end
