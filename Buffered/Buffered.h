//
//  Buffered.h
//  Buffered
//
//  Created by Pawel Niewiadomski on 03.02.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Model.h"

@class GTMOAuth2Authentication;

typedef void(^SignInCompletionHandler)(NSError *error);
typedef void(^CreateUpdateCompletionHandler)(NSError *error);
typedef void(^UpdatesCompletionHandler)(NSString *profileId, NSArray *pending, NSError *error);
typedef void(^RemoveCompletionHandler)(NSString *profileId);

@interface Buffered : NSObject {
    @private SignInCompletionHandler signInHandler;
}

@property GTMOAuth2Authentication* authentication;
@property (strong) NSString *applicationName;
@property (strong, readonly) NSString *clientId;
@property (strong, readonly) NSString *clientSecret;

- (instancetype) initApplication: (NSString *) appName withId: (NSString *) clientId andSecret: (NSString *) clientSecret;

- (void) signInSheetModalForWindow: (NSWindow *) window withCompletionHandler: (SignInCompletionHandler) error;
- (void) signInSheetModalForWindow: (NSWindow *) window withCompletionHandler: (SignInCompletionHandler) handler withControllerClass: (NSString *) class;
- (BOOL) isSignedIn: (BOOL) authorizeFromKeychain;

#pragma mark User
- (void) user: (void (^)(NSDictionary *user, NSError *error)) handler;
#pragma mark -

#pragma mark Profiles
- (void) profiles: (void (^)(NSArray *profiles, NSError *error)) handler ;
#pragma mark -

#pragma mark Updates
- (void) pendingUpdatesForProfile: (NSString *) profileId withCompletionHandler: (UpdatesCompletionHandler) handler ;
- (void) reorderPendingUpdatesForProfile: (NSString *) profileId withOrder: (NSArray *) updateIds withCompletionHandler: (UpdatesCompletionHandler) handler;
- (void) removeUpdate: (NSDictionary *) update withCompletionHandler: (RemoveCompletionHandler) handler;
- (void) shareUpdate: (NSDictionary *) update withCompletionHandler: (RemoveCompletionHandler) handler;
- (void) createUpdate: (BUNewUpdate*) update withCompletionHandler: (CreateUpdateCompletionHandler) handler;
#pragma mark -

@end
