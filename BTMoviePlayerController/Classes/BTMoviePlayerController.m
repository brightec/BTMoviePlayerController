//
//  BTMoviePlayerController.m
//  BTMoviePlayerController
//
//  Created by Cameron Cooke on 12/04/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import "BTMoviePlayerController.h"
#import "BTMoviePlayerView.h"


NSString *const BTMovieDurationAvailableNotification = @"BTMovieDurationAvailableNotification";
NSString *const BTMoviePlayerLoadStateDidChangeNotification = @"BTMoviePlayerLoadStateDidChangeNotification";
NSString *const BTMoviePlayerPlaybackStateDidChangeNotification = @"BTMoviePlayerPlaybackStateDidChangeNotification";
NSString *const BTMoviePlayerLoadedTimeDidChangeNotification = @"BTMoviePlayerLoadedTimeDidChangeNotification";
NSString *const BTMoviePlayerReadyForDisplayDidChangeNotification = @"BTMoviePlayerReadyForDisplayDidChangeNotification";
NSString *const BTMoviePlayerDidPlayToEndTimeNotification = @"BTMoviePlayerDidPlayToEndTimeNotification";
NSString *const BTMoviePlayerMetaDataAvailableNotification = @"BTMoviePlayerMetaDataAvailableNotification";


NSString * const kErrorDomain       = @"uk.co.brightec.btmovieplayercontroller.error";


/* KVO keys */
/* Asset keys */
NSString * const kTracksKey         = @"tracks";
NSString * const kPlayableKey		= @"playable";
NSString * const kCommonMetadataKey = @"commonMetadata";

/* PlayerItem keys */
NSString * const kStatusKey         = @"status";
NSString * const kLoadedTimeRanges  = @"loadedTimeRanges";

/* AVPlayer keys */
NSString * const kRateKey			= @"rate";
NSString * const kCurrentItemKey	= @"currentItem";

/* AVPlayerLayer keys */
NSString * const kReadyForDisplay   = @"readyForDisplay";


static void *BTMoviePlayerControllerRateObservationContext = &BTMoviePlayerControllerRateObservationContext;
static void *BTMoviePlayerControllerStatusObservationContext = &BTMoviePlayerControllerStatusObservationContext;
static void *BTMoviePlayerControllerCurrentItemObservationContext = &BTMoviePlayerControllerCurrentItemObservationContext;
static void *BTMoviePlayerControllerLoadedTimeRangeObservationContext = &BTMoviePlayerControllerLoadedTimeRangeObservationContext;
static void *BTMoviePlayerControllerReadyForDisplayObservationContext = &BTMoviePlayerControllerReadyForDisplayObservationContext;


@interface BTMoviePlayerController ()
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) BTMoviePlayerView *playerView;
@property (assign, nonatomic) BOOL seekToZeroBeforePlay;
@property (strong, nonatomic) NSMutableArray *errors;
@property (strong, nonatomic) AVMutableAudioMix *audioMix;
@end


@implementation BTMoviePlayerController


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // remove kvo observers
    [self.playerItem removeObserver:self forKeyPath:kStatusKey];
    [self.playerItem removeObserver:self forKeyPath:kLoadedTimeRanges];
    [self.player removeObserver:self forKeyPath:kRateKey];
    
    if (self.playerView.layer) {
        [self.playerView.layer removeObserver:self forKeyPath:kReadyForDisplay];
    }
}


- (id)init
{
    return [self initWithContentURL:nil];
}


- (id)initWithContentURL:(NSURL *)contentURL
{
    self = [super init];
    if (self) {
        _contentURL = contentURL;
        _errors = [@[] mutableCopy];
        _volumeLevel = 1.0f;
    }
    return self;
}


- (void)setContentURL:(NSURL *)contentURL
{
    _contentURL = contentURL;
    
    // reset
    self.playerItem = nil;
}


- (void)preapreToPlay
{
    if (self.contentURL == nil) {
        return;
    }
    
    [self.errors removeAllObjects];
    
    // get asset
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.contentURL options:nil];
    NSArray *requestedKeys = @[kTracksKey, kPlayableKey, kCommonMetadataKey];
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
                
        // create player item
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSError *error;
            AVKeyValueStatus status = [asset statusOfValueForKey:kTracksKey error:&error];
            if (!status) {
                NSString *localizedDescription = NSLocalizedString(@"Asset's tracks were not loaded", nil);
                NSString *localizedFailureReason = error.localizedDescription;
                NSDictionary *errorDict = @{NSLocalizedDescriptionKey: localizedDescription,
                                            NSLocalizedFailureReasonErrorKey: localizedFailureReason};
                NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorDict];
                [self assetFailedToPrepareForPlayback:error];
                return;
            }
            
            // make sure that the value of each key has loaded successfully.
            for (NSString *key in requestedKeys) {
                
                NSError *error = nil;
                AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
                if (keyStatus == AVKeyValueStatusFailed) {
                    [self assetFailedToPrepareForPlayback:error];
                    return;
                }
            }

            // create error if asset is not playable
            if (!asset.playable) {
                
                NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
                NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
                NSDictionary *errorDict = @{NSLocalizedDescriptionKey: localizedDescription,
                                            NSLocalizedFailureReasonErrorKey: localizedFailureReason};
                NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorDict];
                [self assetFailedToPrepareForPlayback:error];
                return;
            }
            
            
            // If we've got this far then everything looks ok and ready to play
            
            // get metadata
            if (asset.commonMetadata.count > 0) {
                _commonMetadata = asset.commonMetadata;
                [[NSNotificationCenter defaultCenter] postNotificationName:BTMoviePlayerMetaDataAvailableNotification object:asset.commonMetadata];                
            }

            // if old player item exists remove observers
            if (self.playerItem != nil) {
                [self.playerItem removeObserver:self forKeyPath:kStatusKey];
                [self.playerItem removeObserver:self forKeyPath:kLoadedTimeRanges];                
                [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
            }
            
            // create new instance of player item
            self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
            
            // monitor changes to player item's status key
            [self.playerItem addObserver:self forKeyPath:kStatusKey options:0 context:&BTMoviePlayerControllerStatusObservationContext];
            
            // monitor loaded time range value
            [self.playerItem addObserver:self forKeyPath:kLoadedTimeRanges options:0 context:&BTMoviePlayerControllerLoadedTimeRangeObservationContext];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEndNotification:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:self.playerItem];
            
            self.seekToZeroBeforePlay = NO;
            
            // create new AVPlayer if not already exists
            if (self.player == nil) {
                self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                [self setAllowsAirPlay:_allowsAirPlay];
                
                // monitor rate
                [self.player addObserver:self
                              forKeyPath:kRateKey
                                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                 context:&BTMoviePlayerControllerRateObservationContext];
            }
            
            // replace player item if different from existing item
            if (self.player.currentItem != self.playerItem) {
                [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
            }
            
            [self.playerView setPlayer:self.player];
            
            // play video if autoplay enabled
            if (self.shouldAutoplay) {
                [self play];
            }
        });
    }];
}


#pragma mark -
#pragma mark Error handling

- (void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self.errors addObject:error];
}


# pragma mark -
# pragma mark Notifications

- (void)playerItemDidReachEndNotification:(NSNotification *)notification
{
    if (self.playerItem != notification.object) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BTMoviePlayerDidPlayToEndTimeNotification object:nil];
    
    // move play head back to beginning
    self.seekToZeroBeforePlay = YES;
}


# pragma mark -
# pragma mark KVO Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &BTMoviePlayerControllerStatusObservationContext) {
        
        // AVFoundation does not specficy what thread that this notification will be sent on so make sure we
        // perform any UI work on the main thread.
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.player.currentItem.status == AVPlayerStatusReadyToPlay) {
                [[NSNotificationCenter defaultCenter] postNotificationName:BTMovieDurationAvailableNotification object:nil];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:BTMoviePlayerLoadStateDidChangeNotification object:nil];
            
        });
        return;
    }
    else if (context == &BTMoviePlayerControllerRateObservationContext) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BTMoviePlayerPlaybackStateDidChangeNotification object:nil];
        return;
    }
    else if (context == &BTMoviePlayerControllerLoadedTimeRangeObservationContext) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BTMoviePlayerLoadedTimeDidChangeNotification object:nil];
        return;
    }
    else if (context == &BTMoviePlayerControllerReadyForDisplayObservationContext) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BTMoviePlayerReadyForDisplayDidChangeNotification object:nil];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


# pragma mark -
# pragma mark UI

- (UIView *)view
{
    if (self.playerView == nil) {
        self.playerView = [[BTMoviePlayerView alloc] initWithFrame:CGRectZero];
        self.playerView.backgroundColor = [UIColor blackColor];
        
        [self setScalingMode:_scalingMode];
        
        AVPlayerLayer *layer = (AVPlayerLayer *)self.playerView.layer;
        [layer addObserver:self forKeyPath:kReadyForDisplay options:0 context:&BTMoviePlayerControllerReadyForDisplayObservationContext];
    }
    
    return self.playerView;
}


- (void)setScalingMode:(BTMovieScalingMode)scalingMode
{
    _scalingMode = scalingMode;
    
    AVPlayerLayer *layer = (AVPlayerLayer *)self.playerView.layer;
    switch (scalingMode) {
            
        case BTMovieScalingModeFill:
            layer.videoGravity = AVLayerVideoGravityResize;
            break;
            
        case BTMovieScalingModeAspectFit:
            layer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
            
        case BTMovieScalingModeAspectFill:
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
            
        default:
            layer.videoGravity = @"player";
            break;
    }
}


# pragma mark -
# pragma mark Controling media

- (void)play
{
    if (self.seekToZeroBeforePlay) {
        self.seekToZeroBeforePlay = NO;
        [self.player seekToTime:kCMTimeZero];
    }
    
    [self.player play];
}


- (void)stop
{
    if (self.player == nil) {
        return;
    }
    
    [self.player pause];
    self.currentPlaybackTime = 0;
}


- (void)pause
{
    if (self.player == nil) {
        return;
    }
    
    [self.player pause];
}


# pragma mark -
# pragma mark Volume management

- (void)setVolumeLevel:(float)volumeLevel
{
    _volumeLevel = volumeLevel;
    
    AVPlayerItem *playerItem = self.player.currentItem;
    AVAsset *asset = playerItem.asset;
    
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:volumeLevel atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    
    if (self.audioMix == nil) {
        self.audioMix = [AVMutableAudioMix audioMix];
    }
    
    [self.audioMix setInputParameters:allAudioParams];
    [playerItem setAudioMix:self.audioMix];
}


# pragma mark -
# pragma mark Playback state

- (void)setCurrentPlaybackRate:(float)currentPlaybackRate
{
    self.player.rate = currentPlaybackRate;
}


- (float)currentPlaybackRate
{
    return self.player.rate;
}


- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime
{
    CMTime time = CMTimeMakeWithSeconds(currentPlaybackTime, 600);
    if (CMTIME_IS_INVALID(time)) {
        return;
    }
    
    self.seekToZeroBeforePlay = NO;
    [self.player seekToTime:time];
}


- (NSTimeInterval)currentPlaybackTime
{
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status == AVPlayerStatusReadyToPlay) {
        
        CMTime currentTime = playerItem.currentTime;
        NSTimeInterval interval = CMTimeGetSeconds(currentTime);
        return interval;
    }
    
    return 0;
}


- (NSTimeInterval)playableDuration
{
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    if (loadedTimeRanges.count == 0) {
        return self.duration;
    }
    
    CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}


- (NSTimeInterval)duration
{
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        
        CMTime duration = self.player.currentItem.duration;
        NSTimeInterval interval = CMTimeGetSeconds(duration);
        return interval;
    }
    
    return 0;
}


- (BTMoviePlaybackState)playbackState
{
    if (self.currentPlaybackRate > 0) {
        return BTMoviePlaybackStatePlaying;
    }
    else {
        return BTMoviePlaybackStatePaused;
    }
}


- (BTMovieLoadState)loadState
{
    if (self.player != nil) {
        switch (self.player.status) {
                
            case AVPlayerStatusReadyToPlay:
                
                if (self.player.currentItem.isPlaybackLikelyToKeepUp) {
                    return BTMovieLoadStatePlaythroughOK;
                }
                else {
                    return BTMovieLoadStatePlayable;
                }                
                break;
                
            case AVPlayerStatusFailed:
                return BTMovieLoadStateStalled;
                break;
        }
    }
    
    return BTMovieLoadStateUnknown;
}


- (BOOL)readyForDisplay
{
    AVPlayerLayer *layer = (AVPlayerLayer *)self.playerView.layer;
    return layer.isReadyForDisplay;
}


# pragma mark -
# pragma mark Airplay

- (void)setAllowsAirPlay:(BOOL)allowsAirPlay
{
    _allowsAirPlay = allowsAirPlay;
    
    if ([self.player respondsToSelector:@selector(allowsExternalPlayback)]) {
        self.player.allowsExternalPlayback = allowsAirPlay;
        self.player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
    }
    else {
        self.player.allowsAirPlayVideo = allowsAirPlay;
        self.player.usesAirPlayVideoWhileAirPlayScreenIsActive = YES;
    }
}


- (BOOL)airPlayVideoActive
{
    if ([self.player respondsToSelector:@selector(externalPlaybackActive)]) {
        return self.player.externalPlaybackActive;
    }
    else {
        return self.player.airPlayVideoActive;
    }
}


@end