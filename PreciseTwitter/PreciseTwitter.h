//
//  PreciseTwitter.h
//  PreciseTwitter
//  http://bch.us.to/apps/precisetwitter
//
//  Created by Mahdi Bchetnia on 13/12/13.
//  Copyright (c) 2013 Mahdi Bchetnia. Licensed under GNU GPL v3.0. See LICENSE for details.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface PreciseTwitter : NSObject

+ (PreciseTwitter*)sharedInstance;
- (NSUInteger)newTweetsCount;

@end
