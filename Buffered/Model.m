//
//  Profile.m
//  Buffered
//
//  Created by Pawel Niewiadomski on 17.03.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import "Model.h"
#import "BUPendingUpdatesMonitor.h"

static NSOperationQueue *ATSharedOperationQueue() {
    static NSOperationQueue *_ATSharedOperationQueue = nil;
    if (_ATSharedOperationQueue == nil) {
        _ATSharedOperationQueue = [[NSOperationQueue alloc] init];
        // We limit the concurrency to see things easier for demo purposes. The default value NSOperationQueueDefaultMaxConcurrentOperationCount will yield better results, as it will create more threads, as appropriate for your processor
        [_ATSharedOperationQueue setMaxConcurrentOperationCount:2];
    }
    return _ATSharedOperationQueue;
}

@implementation JSON

- (id) initWithJSON:(NSDictionary *)json withBuffered:(Buffered *)buffered {
    self = [super init];
    if (self) {
        _buffered = buffered;
        self.json = [NSMutableDictionary dictionaryWithDictionary:json];
    }
    return self;
}

- (id) objectAtKeyedSubscript: (id<NSCopying>) key {
    return self.json[key];
}

//- (void) setObject: (id) object forKeyedSubscript:(id<NSCopying>)key {
//    self.json[key] = object;
//}

@end

@implementation Profile

@synthesize updatesMonitor = _updatesMonitor;

- (id) objectAtKeyedSubscript: (id<NSCopying>) key {
    return self.json[key];
}

- (BOOL) isEqual:(id)object {
    if (![object isKindOfClass:[Profile class]]) {
        return NO;
    }
    return [self.id isEqual:((Profile *)object).id];
}

- (NSUInteger) hash {
    return [self.id hash];
}

- (BOOL) inProgress {
    return YES;
}

- (NSString*) id {
    return self.json[@"id"];
}

- (void) loadAvatar {
    @synchronized (self) {
        if (self.avatarImage == nil && !self.avatarLoading) {
            _avatarLoading = YES;
            // We would have to keep track of the block with an NSBlockOperation, if we wanted to later support cancelling operations that have scrolled offscreen and are no longer needed. That will be left as an exercise to the user.
            [ATSharedOperationQueue() addOperationWithBlock:^(void) {
                NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[self.json objectForKey:@"avatar"]]];
                if (image != nil) {
                    // We synchronize access to the image/imageLoading pair of variables
                    @synchronized (self) {
                        _avatarLoading = NO;
                        self.avatarImage = image;
                    }
                } else {
                    _avatarLoading = NO;
                }
            }];
        }
    }
}

- (BUPendingUpdatesMonitor *) updatesMonitor {
    if (_updatesMonitor == nil) {
        _updatesMonitor = [[BUPendingUpdatesMonitor alloc] initWithBuffered:self.buffered andProfile:self];
    }
    return _updatesMonitor;
}

@end

@implementation BUNewUpdate

- (instancetype) init {
    self = [super init];
    if (self) {
        self.shortenLinks = YES;
    }
    return self;
}

+ (instancetype) updateWithText: (NSString *) text andProfiles: (NSArray *) profiles {
    BUNewUpdate * update = [BUNewUpdate new];
    update.text = text;
    __block NSMutableArray *profileIds = [NSMutableArray new];
    [profiles enumerateObjectsUsingBlock:^(Profile* profile, NSUInteger idx, BOOL *stop) {
        [profileIds addObject: profile.id];
    }];
    update.profileIds = profileIds;
    return update;
}

@end
