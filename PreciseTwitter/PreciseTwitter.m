//
//  PreciseTwitter.m
//  PreciseTwitter
//  http://bch.us.to/apps/precisetwitter
//
//  Created by Mahdi Bchetnia on 13/12/13.
//  Copyright (c) 2013 Mahdi Bchetnia. Licensed under GNU GPL v3.0. See LICENSE for details.
//

#import "PreciseTwitter.h"

#pragma mark - Twitter for Mac interface
// Declaring the methods we're going to need/use
@interface NSObject (Twitter)
//Twitter
+ (id)sharedTwitter;
- (id)accounts;
//TwitterAccount
- (id)directMessagesManager;
- (id)timelineStream;
- (id)repliesStream;
- (unsigned long long)tweetNotificationMask;
- (unsigned long long)listNotificationMask;
- (unsigned long long)followNotificationMask;
- (unsigned long long)favoriteNotificationMask;
- (unsigned long long)retweetNotificationMask;
- (unsigned long long)messageNotificationMask;
- (unsigned long long)mentionNotificationMask;
//TwitterConcreteStatusesStream
- (id)statuses;
//TwitterStatus
- (BOOL)isNotADummyStatus;
- (id)comparableDate;
@end

#pragma mark - Replacement methods

@implementation NSObject (PreciseTwitter)

// NSDockTile's setBadgeLabel: replacement method
- (void)new_setBadgeLabel:(NSString*)string {
    if (!string || [string isEqualToString:@""])
        [self new_setBadgeLabel:string];
    else
    {
        NSUInteger count = [[PreciseTwitter sharedInstance] newTweetsCount];
        if (count > 0)
            [self new_setBadgeLabel:[@(count) stringValue]];
        else
            [self new_setBadgeLabel:string];
    }
}

- (void)new_applicationWillTerminate:(id)arg1 {
    // Twitter for Mac is going to quit. Quick, save window position!
    NSWindow* window = [self performSelector:@selector(mainWindow) withObject:nil];
    NSString* savedFrame = NSStringFromRect([window frame]);
    [[NSUserDefaults standardUserDefaults] setObject:savedFrame forKey:@"preciseTwitterWindowFrame"];
    
    [self new_applicationWillTerminate:arg1];
}

@end

#pragma mark - Helpers

@implementation NSObject (Convenience)
// A more convenient way to get object ivars
- (id)getIvar:(NSString*)name {
    return object_getIvar(self, class_getInstanceVariable([self class], [name cStringUsingEncoding:NSUTF8StringEncoding]));
}
@end

#pragma mark - SIMBL methods and loading

@implementation PreciseTwitter

static PreciseTwitter* plugin = nil;

+ (PreciseTwitter*)sharedInstance {
	if (plugin == nil)
		plugin = [[PreciseTwitter alloc] init];
	
	return plugin;
}

+ (void)load {
	[[PreciseTwitter sharedInstance] loadPlugin];
	
	NSLog(@"PreciseTwitter loaded.");
}

- (void)loadPlugin {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"preciseTwitterDisableBadgeCount"])
    {
        Class class = NSClassFromString(@"NSDockTile");
        Method new = class_getInstanceMethod(class, @selector(new_setBadgeLabel:));
        Method old = class_getInstanceMethod(class, @selector(setBadgeLabel:));
        method_exchangeImplementations(new, old);
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"preciseTwitterDisableMultiMonitorFix"])
    {
        Class class = NSClassFromString(@"Tweetie2AppDelegate");
        Method new = class_getInstanceMethod(class, @selector(new_applicationWillTerminate:));
        Method old = class_getInstanceMethod(class, @selector(applicationWillTerminate:));
        method_exchangeImplementations(new, old);
        
        [self restoreWindow];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"preciseTwitterDisableBadgeCount"]
        && [[NSUserDefaults standardUserDefaults] boolForKey:@"preciseTwitterDisableMultiMonitorFix"])
        NSLog(@"Why the hell do you have the plugin installed ?!");
}

#pragma mark - Counting new tweets

- (NSUInteger)newTweetsCount {
    id twitter = [NSClassFromString(@"Twitter") sharedTwitter];
    NSArray* accounts = [twitter accounts];
    
    NSUInteger newTweets = 0;
    
    for (id account in accounts) {
        NSDate* freshTweets = [account getIvar:@"freshTweets"];
        NSDate* freshMentions = [account getIvar:@"freshMentions"];
        NSDate* freshMessages = [account getIvar:@"freshMessages"];
        
        id receivedStream = [[account directMessagesManager] getIvar:@"receivedStream"];
        
        if ([self dockNotificationsEnabledForMask:[account tweetNotificationMask]] && ![freshTweets isEqualToDate:[NSDate distantPast]])
            newTweets += [self newTweetsCountFromStream:[account timelineStream] freshDate:freshTweets];
        
        if ([self dockNotificationsEnabledForMask:[account mentionNotificationMask]] && ![freshMentions isEqualToDate:[NSDate distantPast]])
            newTweets += [self newTweetsCountFromStream:[account repliesStream] freshDate:freshMentions];
        
        if ([self dockNotificationsEnabledForMask:[account messageNotificationMask]] && ![freshMessages isEqualToDate:[NSDate distantPast]])
            newTweets += [self newTweetsCountFromStream:receivedStream freshDate:freshMessages];
    }
    
    return newTweets;
}

- (NSUInteger)newTweetsCountFromStream:(id)stream freshDate:(NSDate*)freshDate {
    NSArray* statuses = [stream statuses];
    NSUInteger newTweets = 0;
    
    for (id status in statuses) {
        if ([status isNotADummyStatus] && ![freshDate isEqualToDate:[status comparableDate]] && [freshDate earlierDate:[status comparableDate]] == freshDate)
            newTweets++;
    }
    
    return newTweets;
}

- (BOOL)dockNotificationsEnabledForMask:(unsigned long long)mask {
    return (mask == 5 || mask == 7 ||  mask == 13 || mask == 15);
}

#pragma mark - Restoring the main window's position

- (void)restoreWindow {
    NSWindow* mainWindow = [[[NSClassFromString(@"NSApplication") sharedApplication] delegate] performSelector:@selector(mainWindow) withObject:nil];

    NSString* savedFrame = [[NSUserDefaults standardUserDefaults] objectForKey:@"preciseTwitterWindowFrame"];
    if (savedFrame)
    {
        NSRect savedRect = NSRectFromString(savedFrame);
        if ([self isWindowVisibleInAnyScreen:savedRect])
        {
            [mainWindow setFrame:savedRect display:YES];
            NSLog(@"Restored Window to %@", savedFrame);
        }
        else
            NSLog(@"Won't restore Window's position because it wouldn't be visible enough.");
    }
}

- (BOOL)isWindowVisibleInAnyScreen:(NSRect)frame {
    CGFloat xHalf = frame.origin.x + frame.size.width/2;
    CGFloat yHalf =  frame.origin.y + frame.size.height/2;
    
    for (NSScreen* screen in [NSClassFromString(@"NSScreen") screens]) {
        CGFloat xFrom = [screen frame].origin.x;
        CGFloat xTo = xFrom+[screen frame].size.width;
        CGFloat yFrom = [screen frame].origin.y;
        CGFloat yTo = yFrom+[screen frame].size.height;
        
        if (xFrom < frame.origin.x && frame.origin.x < xTo &&
            yFrom < frame.origin.y && frame.origin.y < yTo &&
            xHalf < xTo && yHalf < yTo)
            return YES;
    }
    
    return NO;
}

@end
