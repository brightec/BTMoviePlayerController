//
//  BTProgress.m
//
//  Created by Cameron Cooke on 11/04/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import "BTProgress.h"


@implementation BTProgress


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _barColour = [UIColor whiteColor];
        _valueColour = [UIColor colorWithRed:0.000 green:0.365 blue:0.671 alpha:1.000];
        _secondValueColour = [UIColor colorWithWhite:0.853 alpha:1.000];
    }
    return self;
}


- (void)setValue:(float)value
{
    _value = value;
    [self setNeedsDisplay];
}


- (void)setSecondValue:(float)secondValue
{
    _secondValue = secondValue;
    [self setNeedsDisplay];
}


- (void)setBarColour:(UIColor *)barColour
{
    _barColour = barColour;
    [self setNeedsDisplay];
}


- (void)setValueColour:(UIColor *)valueColour
{
    _valueColour = valueColour;
    [self setNeedsDisplay];
}


- (void)setSecondValueColour:(UIColor *)secondValueColour
{
    _secondValueColour = secondValueColour;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // progress bar
    [self.barColour set];
    CGContextFillRect(context, rect);
    
    // second fill
    [self.secondValueColour set];
    CGContextFillRect(context, CGRectMake(0, 0, (self.secondValue * rect.size.width), rect.size.height));
    
    // progress fill
    [self.valueColour set];
    CGContextFillRect(context, CGRectMake(0, 0, (self.value * rect.size.width), rect.size.height));
}

@end
