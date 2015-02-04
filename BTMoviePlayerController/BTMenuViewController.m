//
//  BTMenuViewController.m
//  BTMoviePlayerController
//
//  Created by Cameron Cooke on 15/04/2013.
//  Copyright (c) 2013 Brightec Ltd. All rights reserved.
//

#import "BTMenuViewController.h"
#import "BTVideoPlayerViewController.h"


@interface BTMenuViewController ()
@end


@implementation BTMenuViewController


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BTVideoPlayerViewController *controller = segue.destinationViewController;
    
    if ([segue.identifier isEqual:@"LocalVid"]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"BigBuckBunny_640x360" ofType:@"m4v"];
        controller.contentURL = [NSURL fileURLWithPath:path];
    }
    else if ([segue.identifier isEqual:@"RemoteVid"]) {
        controller.contentURL = [NSURL URLWithString:@"http://static.clipcanvas.com/sample/clipcanvas_14348_offline.mp4"];
    }
    else if ([segue.identifier isEqual:@"Remote2Vid"]) {
        controller.contentURL = [NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
    }
    else if ([segue.identifier isEqual:@"RemoteAudio"]) {
        controller.contentURL = [NSURL URLWithString:@"http://www.largesound.com/ashborytour/sound/brobob.mp3"];
    }
    else if ([segue.identifier isEqual:@"NoVid"]) {
        controller.contentURL = [NSURL URLWithString:@"http://static.clipcanvas.com/sample/clipcanvas_14348_offline.mp400"];
    }
}


@end
