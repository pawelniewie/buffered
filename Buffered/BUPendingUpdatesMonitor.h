//
//  BUPendingUpdatesMonitor.h
//  Buffered
//
//  Created by Pawel Niewiadomski on 05.05.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BUMonitor.h"

@class BUProfile;

@interface BUPendingUpdatesMonitor : BUMonitor {
@private
    NSMutableArray *_pendingUpdates;
}

@property (strong, readonly) NSArray *pendingUpdates;
@property (strong, readonly) NSString *profileId;

- (id) initWithBuffered:(Buffered *)buffered andProfile: (BUProfile *) profile;
- (void) refresh;

@end
