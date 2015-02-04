//
//  TNVideoOverlay.m
//  tennis
//
//  Created by Cameron Cooke on 22/03/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import "TNVideoOverlay.h"


@interface TNVideoOverlay ()
@end


@implementation TNVideoOverlay


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"TNTimelineBar" owner:self options:nil];
    self.timelineBar = views[0];
    self.timelineBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    CGRect timelineFrame = self.timelineBar.frame;
    timelineFrame.size.width = self.topBar.bounds.size.width - self.closeButton.frame.size.width - 8.0f;
    timelineFrame.origin.x = self.closeButton.frame.size.width;
    self.timelineBar.frame = timelineFrame;
    
    [self.topBar addSubview:self.timelineBar];
}


@end
