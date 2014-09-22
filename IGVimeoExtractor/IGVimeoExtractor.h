//
//  IGVimeoExtractor.h
//  IGVimeoExtractor
//
//  Created by Louis Larpin on 18/02/13.
//

#import <Foundation/Foundation.h>

extern NSString *const IGVimeoPlayerConfigURL;
extern NSString *const IGVimeoExtractorErrorDomain;

enum {
    IGVimeoExtractorErrorCodeNotInitialized,
    IGVimeoExtractorErrorInvalidIdentifier,
    IGVimeoExtractorErrorUnsupportedCodec,
    IGVimeoExtractorErrorUnavailableQuality
};

typedef enum IGVimeoVideoQuality : NSUInteger {
    IGVimeoVideoQualityLow,
    IGVimeoVideoQualityMedium,
    IGVimeoVideoQualityHigh
}IGVimeoVideoQuality;

typedef void (^completionHandler) (NSURL *videoURL, NSString* title, NSError *error, IGVimeoVideoQuality quality);

@protocol  IGVimeoExtractorDelegate;

@interface IGVimeoExtractor : NSObject <NSURLConnectionDelegate>

@property (nonatomic, readonly) BOOL running;
@property (nonatomic, readonly) IGVimeoVideoQuality quality;
@property (nonatomic, readonly) NSString* referer;
@property (strong, nonatomic, readonly) NSURL *vimeoURL;

@property (unsafe_unretained, nonatomic) id<IGVimeoExtractorDelegate> delegate;

+ (void)fetchVideoURLFromURL:(NSString *)videoURL quality:(IGVimeoVideoQuality)quality completionHandler:(completionHandler)handler;
+ (void)fetchVideoURLFromID:(NSString *)videoURL quality:(IGVimeoVideoQuality)quality completionHandler:(completionHandler)handler;
+ (void)fetchVideoURLFromURL:(NSString *)videoURL quality:(IGVimeoVideoQuality)quality referer:(NSString *)referer completionHandler:(completionHandler)handler;
+ (void)fetchVideoURLFromID:(NSString *)videoURL quality:(IGVimeoVideoQuality)quality referer:(NSString *)referer completionHandler:(completionHandler)handler;

- (id)initWithURL:(NSString *)videoURL quality:(IGVimeoVideoQuality)quality;
- (id)initWithID:(NSString *)videoID quality:(IGVimeoVideoQuality)quality;
- (id)initWithURL:(NSString *)videoURL quality:(IGVimeoVideoQuality)quality referer:(NSString *)referer;
- (id)initWithID:(NSString *)videoID quality:(IGVimeoVideoQuality)quality referer:(NSString *)referer;

- (void)start;

@end

@protocol IGVimeoExtractorDelegate <NSObject>

- (void)vimeoExtractor:(IGVimeoExtractor *)extractor didSuccessfullyExtractVimeoURL:(NSURL *)videoURL withQuality:(IGVimeoVideoQuality)quality;
- (void)vimeoExtractor:(IGVimeoExtractor *)extractor failedExtractingVimeoURLWithError:(NSError *)error;

@end
