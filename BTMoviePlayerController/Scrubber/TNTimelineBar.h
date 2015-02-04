//
//  TNTimelimeBar.h
//  tennis
//
//  Created by Cameron Cooke on 10/04/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TNTimelineBarDelegate;


@interface TNTimelineBar : UIView
@property (nonatomic) NSTimeInterval value;
@property (nonatomic) NSTimeInterval secondValue;
@property (nonatomic) NSTimeInterval minValue;
@property (nonatomic) NSTimeInterval maxValue;

@property (nonatomic, weak) id<TNTimelineBarDelegate>delegate;
@end


@protocol TNTimelineBarDelegate <NSObject>
- (void)timelineBar:(TNTimelineBar *)timelineBar valueWasChanged:(float)value;
@end