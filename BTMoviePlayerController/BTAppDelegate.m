//
//  BTAppDelegate.m
//  BTMoviePlayerController
//
//  Created by Cameron Cooke on 12/04/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import "BTAppDelegate.h"
#import <AVFoundation/AVFoundation.h>


@implementation BTAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];    
    
    return YES;
}


@end
