//
//  Profile.h
//  Buffered
//
//  Created by Pawel Niewiadomski on 17.03.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BUPendingUpdatesMonitor, Buffered;

@interface BUJSON : NSObject

@property (strong) NSDictionary *json;
@property (weak, readonly) Buffered *buffered;

- (id) initWithJSON: (NSDictionary *) json withBuffered: (Buffered *) buffered;
- (id) objectForKeyedSubscript: (id<NSCopying>) key;
//- (void) setObject: (id) object forKeyedSubscript:(id<NSCopying>)key;

@end

@interface BUProfile : BUJSON

@property (strong) NSImage *avatarImage;
@property (readonly) BOOL avatarLoading;
@property (strong, readonly) BUPendingUpdatesMonitor* updatesMonitor;

- (void) loadAvatar;
- (BOOL) isTwitter;

@end

@interface BUPendingUpdate : BUJSON

@end

/*
 *
 */
@interface BUNewUpdate : NSObject

@property (strong) NSString * text;
@property (strong) NSArray *profileIds;
@property (assign) BOOL shortenLinks;
@property (assign) BOOL shareNow;
@property (assign) BOOL moveToTop;
@property (strong) NSDictionary *media;

- (instancetype) init;

+ (instancetype) updateWithText: (NSString *) text andProfiles: (NSArray *) profiles;

@end