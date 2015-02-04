//
//  BTTimelineBar.h
//
//  Created by Cameron Cooke on 10/04/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BTTimelineBarDelegate;


@interface BTTimelineBar : UIView
@property (nonatomic) NSTimeInterval value;
@property (nonatomic) NSTimeInterval secondValue;
@property (nonatomic) NSTimeInterval minValue;
@property (nonatomic) NSTimeInterval maxValue;

@property (nonatomic, weak) id<BTTimelineBarDelegate>delegate;
@end


@protocol BTTimelineBarDelegate <NSObject>
- (void)timelineBar:(BTTimelineBar *)timelineBar valueWasChanged:(float)value;
@end