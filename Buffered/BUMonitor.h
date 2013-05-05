//
//  BUMonitor.h
//  Buffered
//
//  Created by Pawel Niewiadomski on 05.05.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Buffered;

@protocol BUErrorDelegate <NSObject>

- (void) reportError: (NSError *) error;

@end

// add support for sleep and wake notifications http://developer.apple.com/library/mac/#qa/qa1340/_index.html
@interface BUMonitor : NSObject {
@private
    NSTimer *_updateTimer;
}

@property (assign) BOOL inProgress;

@property (strong) NSError* lastError;

@property (weak) Buffered *buffered;
@property (weak) id<BUErrorDelegate> delegate;

- (id) initWithBuffered: (Buffered *) buffered;
- (void) refresh; // this method is called on each interval
- (void) startPoolingWithInterval: (NSTimeInterval) ti;
- (void) stopPoolling;

@end

