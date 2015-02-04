//
//  BTProgress.h
//
//  Created by Cameron Cooke on 11/04/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BTProgress : UIView
@property (nonatomic) float value;
@property (nonatomic) float secondValue;

@property (nonatomic) UIColor *barColour;
@property (nonatomic) UIColor *valueColour;
@property (nonatomic) UIColor *secondValueColour;
@end
