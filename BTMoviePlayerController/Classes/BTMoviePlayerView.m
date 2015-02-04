//
//  BTMoviePlayerView.m
//  BTMoviePlayerController
//
//  Created by Cameron Cooke on 12/04/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import "BTMoviePlayerView.h"


@implementation BTMoviePlayerView


+ (Class)layerClass
{
    return [AVPlayerLayer class];
}


- (AVPlayer*)player
{
    return [(AVPlayerLayer *)[self layer] player];
}


- (void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}


@end
