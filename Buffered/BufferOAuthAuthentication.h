//
//  BufferOAuthAuthentication.h
//  Buffered
//
//  Created by Pawel Niewiadomski on 14.04.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import "GTMOAuth2Authentication.h"

@interface BufferOAuthAuthentication : GTMOAuth2Authentication

+ (NSString *)encodedQueryParametersForDictionary:(NSDictionary *)dict;

@end
