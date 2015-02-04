//
//  BTMoviePlayerController.h
//  BTMoviePlayerController
//
//  Created by Cameron Cooke on 12/04/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT NSString *const BTMovieDurationAvailableNotification;
FOUNDATION_EXPORT NSString *const BTMoviePlayerLoadStateDidChangeNotification;
FOUNDATION_EXPORT NSString *const BTMoviePlayerPlaybackStateDidChangeNotification;
FOUNDATION_EXPORT NSString *const BTMoviePlayerLoadedTimeDidChangeNotification;
FOUNDATION_EXPORT NSString *const BTMoviePlayerReadyForDisplayDidChangeNotification;
FOUNDATION_EXPORT NSString *const BTMoviePlayerDidPlayToEndTimeNotification;
FOUNDATION_EXPORT NSString *const BTMoviePlayerMetaDataAvailableNotification;



enum {
    BTMoviePlaybackStateStopped,
    BTMoviePlaybackStatePlaying,
    BTMoviePlaybackStatePaused,
    BTMoviePlaybackStateInterrupted,
    BTMoviePlaybackStateSeekingForward,
    BTMoviePlaybackStateSeekingBackward
};
typedef NSInteger BTMoviePlaybackState;


enum {
    BTMovieLoadStateUnknown        = 0,
    BTMovieLoadStatePlayable       = 1 << 0,
    BTMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    BTMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
};
typedef NSInteger BTMovieLoadState;


enum {
    BTMovieScalingModeNone,
    BTMovieScalingModeAspectFit,
    BTMovieScalingModeAspectFill,
    BTMovieScalingModeFill
};
typedef NSInteger BTMovieScalingMode;


@interface BTMoviePlayerController : NSObject
@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readonly) BTMovieLoadState loadState;
@property (nonatomic, readonly) BTMoviePlaybackState playbackState;
@property (nonatomic, readonly) NSTimeInterval playableDuration;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (assign, nonatomic) float volumeLevel;
@property (assign, nonatomic) NSTimeInterval currentPlaybackTime;
@property (assign, nonatomic) float currentPlaybackRate;
@property (assign, nonatomic) BOOL shouldAutoplay;
@property (assign, nonatomic, readonly) BOOL readyForDisplay;
@property (assign, nonatomic) BTMovieScalingMode scalingMode;
@property (assign, nonatomic) BOOL allowsAirPlay;
@property (nonatomic, readonly) BOOL airPlayVideoActive;
@property (nonatomic, copy) NSURL *contentURL;
@property (nonatomic, readonly) NSArray *commonMetadata;


- (id)initWithContentURL:(NSURL *)contentURL;
- (void)setContentURL:(NSURL *)contentURL;
- (void)preapreToPlay;
- (void)play;
- (void)pause;
- (void)stop;
@end