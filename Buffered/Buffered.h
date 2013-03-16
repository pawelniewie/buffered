//
//  Buffered.h
//  Buffered
//
//  Created by Pawel Niewiadomski on 03.02.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTMOAuth2Authentication;

typedef void(^SignInCompletionHandler)(NSError *error);

@interface Buffered : NSObject {
    @private SignInCompletionHandler signInHandler;
}

@property GTMOAuth2Authentication* authentication;
@property (strong) NSString *applicationName;
@property (strong, readonly) NSString *clientId;
@property (strong, readonly) NSString *clientSecret;

- (Buffered *) initApplication: (NSString *) appName withId: (NSString *) clientId andSecret: (NSString *) clientSecret;

- (void) signInSheetModalForWindow: (NSWindow *) window withCompletionHandler: (SignInCompletionHandler) error;
- (BOOL) isSignedIn: (BOOL) authorizeFromKeychain;

#pragma mark User
- (void) user: (void (^)(NSDictionary *user, NSError *error)) handler;
#pragma mark -

#pragma mark Profiles
- (void) profiles: (void (^)(NSArray *profiles, NSError *error)) handler ;
#pragma mark -

#pragma mark Updates
- (void) pendingUpdatesForProfile: (NSString *) profileId withCompletionHandler: (void (^)(NSArray *updates, NSError *error)) handler ;
#pragma mark -

@end
