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
    NSMutableSet *_profiles;
}

@property (strong) NSSet* profiles;

- (id) initWithBuffered: (Buffered *) buffered;
- (void) refresh;

@end
