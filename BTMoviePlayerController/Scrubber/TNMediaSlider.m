//
//  TNTimeline.m
//  tennis
//
//  Created by Cameron Cooke on 10/04/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import "TNMediaSlider.h"


@implementation TNMediaSlider


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setThumbImage:[UIImage imageNamed:@"sliderThumb"] forState:UIControlStateNormal];
    [self setThumbImage:[UIImage imageNamed:@"sliderThumb"] forState:UIControlStateHighlighted];    
    
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self setMaximumTrackImage:transparentImage forState:UIControlStateNormal];    
}


- (CGRect)trackRectForBounds:(CGRect)bounds
{
    CGRect result = [super trackRectForBounds:bounds];
    result.size.height = 10.0f;
    return result;
}


@end
