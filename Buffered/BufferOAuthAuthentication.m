//
//  BufferOAuthAuthentication.m
//  Buffered
//
//  Created by Pawel Niewiadomski on 14.04.2013.
//  Copyright (c) 2013 Pawel Niewiadomski. All rights reserved.
//

#import "BufferOAuthAuthentication.h"

@implementation BufferOAuthAuthentication

+ (NSString *)encodedQueryParametersForDictionary:(NSDictionary *)dict {
    // Make a string like "cat=fluffy@dog=spot"
    NSMutableString *result = [NSMutableString string];
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSString *joiner = @"";
    for (NSString *key in sortedKeys) {
        NSString *value = [dict objectForKey:key];
        if (![[NSNull null] isEqualTo:value]) {
            NSString *encodedValue = [self encodedOAuthValueForString:value];
            NSString *encodedKey = [self encodedOAuthValueForString:key];
            [result appendFormat:@"%@%@=%@", joiner, encodedKey, encodedValue];
            joiner = @"&";
        }
    }
    return result;
}

@end
