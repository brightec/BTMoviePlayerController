//
//  TNTimelimeBar.m
//  tennis
//
//  Created by Cameron Cooke on 10/04/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import "TNTimelineBar.h"
#import "TNProgress.h"
#import "TNMediaSlider.h"

@interface TNTimelineBar ()
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *lengthLabel;
@property (nonatomic, weak) IBOutlet TNMediaSlider *mediaSlider;
@property (nonatomic, strong) TNProgress *progressBar;
@property (nonatomic) BOOL isTouchingDown;
@end



@implementation TNTimelineBar


- (void)dealloc
{
    [self.mediaSlider removeTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.mediaSlider removeTarget:self action:@selector(sliderTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];    
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.mediaSlider.minimumValue = 0;
    self.mediaSlider.maximumValue = 0;
    self.mediaSlider.continuous = YES;
    [self.mediaSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.mediaSlider addTarget:self action:@selector(sliderTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.mediaSlider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    
    // create progress bar
    TNProgress *progressBar = [[TNProgress alloc] initWithFrame:CGRectZero];
    progressBar.autoresizesSubviews = self.mediaSlider.autoresizingMask;
    progressBar.value = 0.0f;
    progressBar.secondValue = 0.0f;
    [self insertSubview:progressBar belowSubview:self.mediaSlider];
    self.progressBar = progressBar;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat progressBarHeight = 10.0f;
    CGFloat progressBarWidth = self.mediaSlider.frame.size.width;
    CGRect progressBarFrame = CGRectMake(self.mediaSlider.frame.origin.x, (self.bounds.size.height / 2) - (progressBarHeight / 2), progressBarWidth, progressBarHeight);
    self.progressBar.frame = progressBarFrame;
}


- (void)sliderValueChanged:(TNMediaSlider *)slider
{
    self.timeLabel.text = [self timeAsFormattedString:slider.value];    
}


- (void)sliderTouchedUpInside:(TNMediaSlider *)slider
{
    NSLog(@"Touch up!");
    self.value = slider.value;
    [self.delegate timelineBar:self valueWasChanged:self.value];
    self.isTouchingDown = NO;    
}

- (void)sliderTouchDown:(TNMediaSlider *)slider
{
    NSLog(@"Touch down!");
    self.isTouchingDown = YES;
}


- (void)setValue:(NSTimeInterval)value
{
    _value = value;
    
    if (self.isTouchingDown) {
        return;
    }
    
    self.timeLabel.text = [self timeAsFormattedString:value];
    self.mediaSlider.value = value;
    self.progressBar.value = value / self.maxValue;
}


- (void)setSecondValue:(NSTimeInterval)secondValue
{
    _secondValue = secondValue;
    if (self.isTouchingDown) {
        return;
    }
    
    self.progressBar.secondValue = secondValue / self.maxValue;
}


- (void)setMaxValue:(NSTimeInterval)maxValue
{
    _maxValue = maxValue;
    
    self.mediaSlider.maximumValue = maxValue;
    self.lengthLabel.text = [self timeAsFormattedString:maxValue];
}


- (NSString *)timeAsFormattedString:(NSTimeInterval)timeInterval
{
    NSDate *date = [NSDate date];
    NSDate *intevalDate = [date dateByAddingTimeInterval:timeInterval];
    
    unsigned int theUnits = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:theUnits fromDate:date toDate:intevalDate options:0];
    
    NSString *timeString = nil;
    if ([dateComponents hour] > 0) {
        timeString = [NSString stringWithFormat:@"%02d.%02d.%02d", [dateComponents hour], [dateComponents minute], [dateComponents second]];
    }
    else {
        timeString = [NSString stringWithFormat:@"%02d.%02d", [dateComponents minute], [dateComponents second]];;
    }
    
    return timeString;
}


@end