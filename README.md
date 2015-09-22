## IGVimeoExtractor

IGVimeoExtractor helps you get mp4 urls which can be use in iOS's native player. You can even choose between mobile, standard and high definition quality.

IGVimeoExtractor doesn't use UIWebView which makes it fast and clean.

IGVimeoExtractor is a forkof YTVimeoExtractor.

## Install

The preferred way of installation is via [CocoaPods](http://cocoapods.org). Just add to your Podfile

```ruby
pod 'IGVimeoExtractor'
```

and run `pod install`.

Alternatively you can just copy the IGVimeoExtractor folder to your project.

```objc
#import "IGVimeoExtractor.h"
```

## Usage

Use the block based methods and pass it the video url and the desired quality

```objc
[IGVimeoExtractor fetchVideoURLFromURL:self.textURL.text quality:self.quality completionHandler:^(IGVimeoVideo* video, NSError *error) {
    if (error) {
        NSLog(@"Error : %@", [error localizedDescription]);
    } else if (video) {
        NSLog(@"Extracted url : %@, title: %@", [video.videoURL absoluteString], video.title);
        
        self.playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:video.videoURL];
        [self.playerView.moviePlayer prepareToPlay];
        [self presentViewController:self.playerView animated:YES completion:^(void) {
            self.playerView = nil;
        }];
    }
}];
```

or create an instance of IGVimeoExtractor.

```objc
self.extractor = [[IGVimeoExtractor alloc] initWithURL:@"http://vimeo.com/58600663" quality:YTVimeoVideoQualityMedium];
self.extractor.delegate = self;
[self.extractor start];
```

and implement YTVimeoExtractor delegate methods in your ViewController.

```objc
- (void)vimeoExtractor:(IGVimeoExtractor * _Nonnull)extractor didSuccessfullyExtractVimeoVideos:(NSArray<IGVimeoVideo*>* _Nonnull)videos
{
    // handle success
}

- (void)vimeoExtractor:(IGVimeoExtractor *)extractor failedExtractingVimeoURLWithError:(NSError *)error;
{
    // handle error
}
```

If the Vimeo videos have domain-level restrictions and can only be played from particular domains, it's easy to add a referer:

```objc
[YTVimeoExtractor fetchVideoURLFromURL:@"http://vimeo.com/58600663"
                               referer:@"http://www.mywebsite.com"
                     completionHandler:^(IGVimeoVideo* video, NSError *error) {
// handle results
}];
```

Check the sample application for more details.

## Requirements

YTVimeoExtractor requires iOS 7.0 and above as it is deployed for an ARC environment.

## License

YTVimeoExtractor is licensed under the MIT License. See the LICENSE file for details.
