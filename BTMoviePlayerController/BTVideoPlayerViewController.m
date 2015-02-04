//
//  BTViewController.m
//  BTMoviePlayerController
//
//  Created by Cameron Cooke on 12/04/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import "BTVideoPlayerViewController.h"
#import "BTVideoOverlay.h"
#import "BTMoviePlayerController.h"
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>


@interface BTVideoPlayerViewController ()
@property (strong, nonatomic) BTMoviePlayerController *moviePlayerController;
@property (strong, nonatomic) BTVideoOverlay *overlayView;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) float preMuteVolumeLevel;
@property (assign, nonatomic) BTMovieScalingMode scalingMode;
@property (strong, nonatomic) MPVolumeView *volumeView;
@end


@implementation BTVideoPlayerViewController


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
    self.timer = nil;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDurationAvailableNotification:) name:BTMovieDurationAvailableNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackStateChangedNotification:) name:BTMoviePlayerPlaybackStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackLoadedTimeDidChangeNotification:) name:BTMoviePlayerLoadedTimeDidChangeNotification object:nil];
        
        _scalingMode = BTMovieScalingModeNone;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // create overlay controls view
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"BTVideoOverlay" owner:self options:nil];
    BTVideoOverlay *overlayView = views[0];
    overlayView.frame = self.view.bounds;
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    overlayView.backgroundColor = [UIColor clearColor];
    overlayView.opaque = NO;
    [self.view addSubview:overlayView];
    self.overlayView = overlayView;
    
    // create movie player controller
    self.moviePlayerController = [[BTMoviePlayerController alloc] init];
    [self.moviePlayerController setContentURL:self.contentURL];
    self.moviePlayerController.scalingMode = self.scalingMode;
    self.moviePlayerController.allowsAirPlay = YES;
    
    UIView *view = self.moviePlayerController.view;
    view.frame = self.view.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:view atIndex:0];
    [self updateButtonStates];
    
    // add airplay icon
    UIView *bottomBar = self.overlayView.volumeButton.superview;
    
    self.volumeView = [[MPVolumeView alloc] init];
    [self.volumeView setShowsVolumeSlider:NO];
    [self.volumeView sizeToFit];
    
    CGRect volumeViewFrame = self.volumeView.frame;
    volumeViewFrame.origin.x = self.overlayView.volumeButton.frame.origin.x - volumeViewFrame.size.width;
    volumeViewFrame.origin.y = (bottomBar.frame.size.height / 2) - (volumeViewFrame.size.height / 2);
    self.volumeView.frame = volumeViewFrame;
    
    [bottomBar addSubview:self.volumeView];
    
    // add event listeners
    [overlayView.playPauseButton addTarget:self action:@selector(playPauseButtonWasTouched:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView.stopButton addTarget:self action:@selector(stopButtonWasTouched:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView.speedButton addTarget:self action:@selector(speedButtonWasTouched:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView.volumeButton addTarget:self action:@selector(volumeButtonWasTouched:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView.muteButton addTarget:self action:@selector(muteButtonWasTouched:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView.closeButton addTarget:self action:@selector(closeButtonWasTouched:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView.volumeSlider addTarget:self action:@selector(volumeSliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    overlayView.timelineBar.delegate = self;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self playPauseButtonWasTouched:self.overlayView.playPauseButton];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    [self.moviePlayerController preapreToPlay];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.moviePlayerController stop];

    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}



- (BOOL)canBecomeFirstResponder
{
    return YES;
}


# pragma mark -
# pragma mark BTVideoOverlay

- (void)playPauseButtonWasTouched:(UIButton *)playButton
{
    if (self.moviePlayerController.playbackState == BTMoviePlaybackStatePlaying) {
        [self.moviePlayerController pause];
    }
    else {
        [self.moviePlayerController play];
    }
    
    [self updateButtonStates];
    
    if (self.timer == nil) {
        self.timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(timerIntervalFired:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
}


- (void)stopButtonWasTouched:(UIButton *)stopButton
{
    [self.moviePlayerController stop];
}


- (void)speedButtonWasTouched:(UIButton *)speedButton
{
    if (self.moviePlayerController.currentPlaybackRate == 1) {
        self.moviePlayerController.currentPlaybackRate = 0.5f;
    }
    else {
        self.moviePlayerController.currentPlaybackRate = 1.0f;
    }
    
    [self updateButtonStates];
}


- (void)closeButtonWasTouched:(UIButton *)closeButton
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)timelineBar:(BTTimelineBar *)timelineBar valueWasChanged:(float)value
{
    self.moviePlayerController.currentPlaybackTime = value;
}


# pragma mark Volume controls

- (void)muteButtonWasTouched:(UIButton *)volumeButton
{
    if (self.moviePlayerController.volumeLevel > 0) {
        self.preMuteVolumeLevel = self.moviePlayerController.volumeLevel;
        self.moviePlayerController.volumeLevel = 0;
    }
    else {
        self.moviePlayerController.volumeLevel = self.preMuteVolumeLevel;
    }
    [self updateButtonStates];    
}


- (void)volumeButtonWasTouched:(UIButton *)volumeButton
{
    [self updateButtonStates];
    self.overlayView.volumeBar.hidden = !self.overlayView.volumeBar.hidden;
}


- (void)volumeSliderValueDidChange:(UISlider *)volumeSlider
{
    self.moviePlayerController.volumeLevel = volumeSlider.value;
    [self updateButtonStates];
}


# pragma mark -
# pragma mark UI state

- (void)updateButtonStates
{
    UIButton *playButton = self.overlayView.playPauseButton;
    switch (self.moviePlayerController.playbackState) {
            
        case BTMoviePlaybackStateInterrupted:
        case BTMoviePlaybackStatePaused:
        case BTMoviePlaybackStateStopped:
            [playButton setImage:[UIImage imageNamed:@"playIcon"] forState:UIControlStateNormal];
            break;
            
        case BTMoviePlaybackStatePlaying:
            [playButton setImage:[UIImage imageNamed:@"pauseIcon"] forState:UIControlStateNormal];
            break;
            
        case BTMoviePlaybackStateSeekingForward:
            break;
            
        case BTMoviePlaybackStateSeekingBackward:
            break;
            
        default:
            break;
    }
    
    // speed button
    UIButton *slowMoButton = self.overlayView.speedButton;
    if (self.moviePlayerController.currentPlaybackRate == 0.5) {
        [slowMoButton setBackgroundImage:[UIImage imageNamed:@"iconBack"] forState:UIControlStateNormal];
    }
    else {
        [slowMoButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
    
    // mute button
    UIButton *muteButton = self.overlayView.muteButton;
    if (self.moviePlayerController.volumeLevel > 0) {
        [muteButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
    else {
        [muteButton setBackgroundImage:[UIImage imageNamed:@"iconBack"] forState:UIControlStateNormal];
    }
    
    self.overlayView.volumeSlider.value = self.moviePlayerController.volumeLevel;
}


- (void)updateTimelimeBar
{
    self.overlayView.timelineBar.value = self.moviePlayerController.currentPlaybackTime;
}


# pragma mark -
# pragma mark Notifications

- (void)movieDurationAvailableNotification:(NSNotification *)notification
{
    self.overlayView.timelineBar.maxValue = self.moviePlayerController.duration;
}


- (void)moviePlaybackLoadedTimeDidChangeNotification:(NSNotification *)notification
{
    self.overlayView.timelineBar.secondValue = self.moviePlayerController.playableDuration;
}


- (void)moviePlaybackStateChangedNotification:(NSNotification *)notification
{
    [self updateTimelimeBar];
    [self updateButtonStates];
}


# pragma mark -
# pragma mark NSTimer

- (void)timerIntervalFired:(NSTimer *)timer
{
    NSLog(@"Playback time: %f", self.moviePlayerController.currentPlaybackTime);
    
//    if (self.moviePlayerController.playbackState != MPMoviePlaybackStatePlaying) {
//        return;
//    }
    
    [self updateTimelimeBar];
}


# pragma mark -
# pragma mark Gestures

- (IBAction)doubleTapGestureWasPerformed:(UITapGestureRecognizer *)sender
{
    if (self.scalingMode == BTMovieScalingModeAspectFill) {
        self.moviePlayerController.scalingMode = BTMovieScalingModeNone;
    }
    else {
        self.moviePlayerController.scalingMode = BTMovieScalingModeAspectFill;
    }
    
    self.scalingMode = self.moviePlayerController.scalingMode;
}


# pragma mark -
# pragma mark Airplay remote control events

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                
                if (self.moviePlayerController.playbackState == BTMoviePlaybackStatePlaying) {
                    [self.moviePlayerController pause];
                }
                else {
                    [self.moviePlayerController play];
                }                
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                self.moviePlayerController.currentPlaybackTime = 0.0f;
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                self.moviePlayerController.currentPlaybackTime = self.moviePlayerController.duration;
                break;
                
            default:
                break;
        }
    }
}


@end
