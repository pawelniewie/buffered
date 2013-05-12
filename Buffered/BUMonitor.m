//
//  BUMonitor.m
//  Buffered
//
//  Created by Pawel Niewiadomski on 05.05.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import "BUMonitor.h"

@implementation BUMonitor

- (id) initWithBuffered:(Buffered *)buffered {
    assert(buffered != nil);
    
    self = [super init];
    if (self) {
        self.buffered = buffered;
    }
    return self;
}

- (void) dealloc {
    [self stopPoolling];
}

- (void) refresh {
}

- (BOOL) isPooling {
    return _updateTimer != nil;
}

- (void) startPoolingWithInterval:(NSTimeInterval)ti {
    if (_updateTimer != nil) {
        [_updateTimer invalidate];
    }
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(refresh) userInfo:nil repeats:YES];
}

- (void) stopPoolling {
    [_updateTimer invalidate];
    _updateTimer = nil;
}

@end
