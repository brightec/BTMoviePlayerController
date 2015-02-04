//
//  BTViewController.h
//  BTMoviePlayerController
//
//  Created by Cameron Cooke on 12/04/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TNTimelineBar.h"


@interface BTVideoPlayerViewController : UIViewController <TNTimelineBarDelegate>
@property (nonatomic) NSURL *contentURL;
@end