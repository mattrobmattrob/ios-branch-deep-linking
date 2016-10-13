//
//  Branch+iAd.m
//  Branch-TestBed
//
//  Created by edward on 10/13/16.
//  Copyright © 2016 Branch Metrics. All rights reserved.
//


#import "Branch+iAd.h"
#import "BNCError.h"
#import <iAd/iAd.h>


@implementation Branch (iAd)

- (void) checkAppleSearchAttributionWithCompletion:
        (void (^)(NSDictionary *attributionDetails, NSError *error))completion
    {
    Class ADClientClass = NSClassFromString(@"ADClient");
    if (!ADClientClass)
        {
        NSError *error =
            [NSError errorWithDomain:BNCErrorDomain
                code:BNCiAdNotAvailable userInfo:nil];
        if (completion)
            completion(nil, error);
        return;
        }
    [[ADClientClass sharedClient]
        requestAttributionDetailsWithBlock:
        ^ (NSDictionary *details, NSError *error)
            {
            NSLog(@"Attribution error: %@ info:\n%@", error, details);
            }];
    }

@end
