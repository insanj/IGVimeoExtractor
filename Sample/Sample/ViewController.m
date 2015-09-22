//
//  ViewController.m
//  Sample
//
//  Created by Louis on 18/02/13.
//  Copyright (c) 2013 Louis Larpin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IGVimeoExtractor *extractor;
@property (strong, nonatomic) MPMoviePlayerViewController *playerView;
@property (nonatomic) IGVimeoVideoQuality quality;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.quality = IGVimeoVideoQualityMedium;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)playVideo:(id)sender
{
    [IGVimeoExtractor fetchVideoURLFromURL:self.textURL.text completionHandler:^(NSArray<IGVimeoVideo*>* videos, NSError *error) {
        if (error) {
            NSLog(@"Error : %@", [error localizedDescription]);
        } else if ([videos count] > 0) {
            NSLog(@"Extracted videos: %@", videos);
            
            self.playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:videos.firstObject.videoURL];
            [self.playerView.moviePlayer prepareToPlay];
            [self presentViewController:self.playerView animated:YES completion:^(void) {
                self.playerView = nil;
            }];
        }
    }];
}

- (IBAction)changeQuality
{
    switch (self.qualitySeg.selectedSegmentIndex) {
        case 0:
            self.quality = IGVimeoVideoQualityLow;
            break;
        case 1:
            self.quality = IGVimeoVideoQualityMedium;
            break;
        case 2:
            self.quality = IGVimeoVideoQualityHigh;
            
        default:
            break;
    }
}

@end
