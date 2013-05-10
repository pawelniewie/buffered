//
//  Profile.h
//  Buffered
//
//  Created by Pawel Niewiadomski on 17.03.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BUPendingUpdatesMonitor, Buffered;

@interface JSON : NSObject

@property (strong) NSDictionary *json;
@property (weak, readonly) Buffered *buffered;

- (id) initWithJSON: (NSDictionary *) json withBuffered: (Buffered *) buffered;

@end

@interface Profile : JSON

@property (strong) NSImage *avatarImage;
@property (readonly) BOOL avatarLoading;
@property (strong, readonly) NSString* id;
@property (strong, readonly) BUPendingUpdatesMonitor* updatesMonitor;

- (void) loadAvatar;

@end

@interface Update : JSON<NSPasteboardReading, NSPasteboardWriting>

@end