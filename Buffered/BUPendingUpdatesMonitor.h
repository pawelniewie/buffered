//
//  BUPendingUpdatesMonitor.h
//  Buffered
//
//  Created by Pawel Niewiadomski on 05.05.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BUMonitor.h"

@class Profile;

@interface BUPendingUpdatesMonitor : BUMonitor {
@private
    NSMutableArray *_pendingUpdates;
}

@property (strong) NSArray *pendingUpdates;
@property (strong) NSString *profileId;

- (id) initWithBuffered:(Buffered *)buffered andProfile: (Profile *) profile;
- (void) refresh;

@end
