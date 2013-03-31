//
//  Buffered.m
//  Buffered
//
//  Created by Pawel Niewiadomski on 03.02.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import <GTMOAuth2Authentication.h>
#import <GTMOAuth2WindowController.h>
#import "Buffered.h"
#import "Model.h"

@implementation Buffered

- (Buffered *) initApplication: (NSString *) appName withId: (NSString *) clientId andSecret: (NSString *) clientSecret {
    self = [self init];
    if (self) {
        _applicationName = appName;
        _clientId = clientId;
        _clientSecret = clientSecret;
        _authentication = [self bufferAuthentication];
    }
    return self;
}

- (BOOL) authorizeFromKeychain {
    return [GTMOAuth2WindowController authorizeFromKeychainForName:self.applicationName authentication:self.authentication];
}

- (GTMOAuth2Authentication *) bufferAuthentication {
    NSURL *tokenURL = [NSURL URLWithString:@"https://api.bufferapp.com/1/oauth2/token.json"];
    
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:self.applicationName
                                                             tokenURL:tokenURL
                                                          redirectURI:[GTMOAuth2SignIn nativeClientRedirectURI]
                                                             clientID:self.clientId
                                                         clientSecret:self.clientSecret];
    return auth;
}

- (void)signOut {

}

- (NSBundle *) GTMOAuth2Bundle {
    NSString *frameworkBundleID = @"com.google.GTMOAuth2NonGoogle";
    NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:frameworkBundleID];
    return frameworkBundle;
}

- (void) signInSheetModalForWindow: (NSWindow *) window withCompletionHandler: (SignInCompletionHandler) handler {
    [self signOut];
    signInHandler = handler;
    
    GTMOAuth2Authentication *auth = [self bufferAuthentication];
    
    NSURL *authURL = [NSURL URLWithString:@"https://bufferapp.com/oauth2/authorize"];
    
    // Display the authentication view
    GTMOAuth2WindowController *windowController;
    windowController = [[GTMOAuth2WindowController alloc] initWithAuthentication:auth authorizationURL:authURL keychainItemName:self.applicationName resourceBundle:[self GTMOAuth2Bundle]];
    
    [windowController signInSheetModalForWindow:window
                                 delegate:self
                         finishedSelector:@selector(windowController:finishedWithAuth:error:)];
}

- (BOOL)isSignedIn:(BOOL) authorizeFromKeychain {
    if (authorizeFromKeychain) {
        [self authorizeFromKeychain];
    }
    return [self.authentication canAuthorize];
}

- (void)windowController:(GTMOAuth2WindowController *)windowController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    signInHandler(error);
}

- (GTMHTTPFetcher *) newFetcher: (NSString *) url {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [myFetcher setAuthorizer:_authentication];
    return myFetcher;
}


#pragma mark User
- (void) user: (void (^)(NSDictionary *user, NSError *error)) handler {
    GTMHTTPFetcher* myFetcher = [self newFetcher:@"https://api.bufferapp.com/1/user.json"];
    [myFetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
        if (error != nil) {
            handler(nil, error);
        } else {
            NSDictionary* user = [NSJSONSerialization
                               JSONObjectWithData:retrievedData
                               options:NSJSONReadingMutableLeaves
                               error:&error];
            if (error != nil) {
                handler(nil, error);
            } else {
                handler(user, nil);
            }
        }
    }];
}
#pragma mark -

#pragma mark Profiles
- (void) profiles: (void (^)(NSArray *user, NSError *error)) handler  {
    GTMHTTPFetcher* myFetcher = [self newFetcher:@"https://api.bufferapp.com/1/profiles.json"];
    [myFetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
        if (error != nil) {
            handler(nil, error);
        } else {
            NSArray* profiles = [NSJSONSerialization
                                  JSONObjectWithData:retrievedData
                                  options:NSJSONReadingMutableLeaves
                                  error:&error];
            if (error != nil) {
                handler(nil, error);
            } else {
                handler([self asProfiles:profiles], nil);
            }
        }
    }];
}

- (NSArray*) asProfiles: (NSArray*) jsonArray {
    NSMutableArray *profiles = [NSMutableArray array];
    for (NSDictionary *json in jsonArray) {
        [profiles addObject: [[Profile alloc] initWithJSON: json]];
    }
    return profiles;
}
#pragma mark -

#pragma mark Updates
- (void) pendingUpdatesForProfile: (NSString *) profileId withCompletionHandler: (UpdatesCompletionHandler) handler {
    GTMHTTPFetcher* myFetcher = [self newFetcher:[NSString stringWithFormat:@"https://api.bufferapp.com/1/profiles/%@/updates/pending.json", profileId]];
    [myFetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
        if (error != nil) {
            handler(profileId, nil, error);
        } else {
            NSDictionary* updates = [NSJSONSerialization
                                 JSONObjectWithData:retrievedData
                                 options:NSJSONReadingMutableLeaves
                                 error:&error];
            if (error != nil) {
                handler(profileId, nil, error);
            } else {
                handler(profileId, [updates objectForKey:@"updates"], nil);
            }
        }
    }];
}

- (void) reorderPendingUpdatesForProfile: (NSString *) profileId withOrder: (NSArray *) updateIds withCompletionHandler: (UpdatesCompletionHandler) handler {
    GTMHTTPFetcher* myFetcher = [self newFetcher:[NSString stringWithFormat:@"https://api.bufferapp.com/1/profiles/%@/updates/reorder.json", profileId]];
    NSMutableString *postData = [NSMutableString new];
    for (NSString *updateId in updateIds) {
        [postData appendString: @"order[]="];
        [postData appendString: updateId];
        [postData appendString: @"&"];
    }
    myFetcher.postData = [postData dataUsingEncoding:NSUTF8StringEncoding];
    [myFetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
        if (error != nil) {
            handler(profileId, nil, error);
        } else {
            NSDictionary* updates = [NSJSONSerialization
                                     JSONObjectWithData:retrievedData
                                     options:NSJSONReadingMutableLeaves
                                     error:&error];
            if (error != nil) {
                handler(profileId, nil, error);
            } else {
                handler(profileId, [updates objectForKey:@"updates"], nil);
            }
        }
    }];
}
#pragma mark -

@end