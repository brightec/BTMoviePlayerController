//
//  TNVideoOverlay.h
//  tennis
//
//  Created by Cameron Cooke on 22/03/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TNTimelineBar.h"

@interface TNVideoOverlay : UIView
@property (nonatomic, weak) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *speedButton;
@property (nonatomic, weak) IBOutlet UIButton *volumeButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIView *topBar;
@property (nonatomic, strong) TNTimelineBar *timelineBar;

@property (weak, nonatomic) IBOutlet UIView *volumeBar;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;

@end