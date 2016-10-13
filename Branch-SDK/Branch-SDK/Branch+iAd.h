//
//  Branch+iAd.h
//  Branch
//
//  Created by Edward Smith on 10/13/16.
//  Copyright © 2016 Branch Metrics. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Branch.h"

@interface Branch (iAd)
- (void) checkAppleSearchAttributionWithCompletion:
    (void (^)(NSDictionary *attributionDetails, NSError *error))completion;
@end
