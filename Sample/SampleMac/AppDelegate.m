//
//  AppDelegate.m
//  SampleMac
//
//  Created by Francis Chong on 19/9/14.
//  Copyright (c) 2014 Louis Larpin. All rights reserved.
//

#import "AppDelegate.h"
#import "YTVimeoExtractor.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [YTVimeoExtractor fetchVideoURLFromURL:@"https://vimeo.com/105646584" quality:YTVimeoVideoQualityHigh completionHandler:^(NSURL *videoURL, NSError *error, YTVimeoVideoQuality quality) {
        if (error) {
            NSLog(@"Error : %@", [error localizedDescription]);
        } else if (videoURL) {
            NSLog(@"Extracted url : %@", [videoURL absoluteString]);
        }
    }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
