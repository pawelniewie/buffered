//
//  BUProfilesMonitor.m
//  Buffered
//
//  Created by Pawel Niewiadomski on 03.05.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import "Buffered.h"
#import "BUProfilesMonitor.h"

@implementation BUProfilesMonitor

- (id) initWithBuffered:(Buffered *)buffered {
    self = [super initWithBuffered:buffered];
    if (self) {
        _profiles = [NSMutableArray new];
    }
    return self;
}

- (void) refresh {
    self.inProgress = YES; // don't care if it's called twice, we just want to have some indicator it's in progress
    
    [self.buffered profiles:^(NSArray *profiles, NSError *error) {
        self.inProgress = NO;
        
        if (profiles != nil) {
            [self willChangeValueForKey:@"profiles"];
            [_profiles removeAllObjects];
            [_profiles addObjectsFromArray:profiles];
            [self didChangeValueForKey:@"profiles"];
        } else {
            self.lastError = error;
            if (self.delegate != nil) {
                [self.delegate reportError:error];
            }
        }
    }];
}

@end
