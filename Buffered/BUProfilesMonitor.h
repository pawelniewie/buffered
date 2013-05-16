//
//  BUProfilesMonitor.h
//  Buffered
//
//  Created by Pawel Niewiadomski on 03.05.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BUMonitor.h"

@interface BUProfilesMonitor : BUMonitor {
@private
    NSMutableArray *_profiles;
}

@property (strong, readonly) NSArray* profiles;

- (id) initWithBuffered: (Buffered *) buffered;
- (void) refresh;

@end
