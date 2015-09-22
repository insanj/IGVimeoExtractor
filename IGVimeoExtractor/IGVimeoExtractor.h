//
//  IGVimeoExtractor.h
//  IGVimeoExtractor
//
//  Created by Louis Larpin on 18/02/13.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull const IGVimeoPlayerConfigURL;
extern NSString * _Nonnull const IGVimeoExtractorErrorDomain;

enum {
    IGVimeoExtractorErrorCodeNotInitialized,
    IGVimeoExtractorErrorInvalidIdentifier,
    IGVimeoExtractorErrorUnsupportedCodec,
    IGVimeoExtractorErrorUnavailableQuality,
    IGVimeoExtractorErrorUnexpected
};

typedef enum IGVimeoVideoQuality : NSUInteger {
    IGVimeoVideoQualityLow,
    IGVimeoVideoQualityMedium,
    IGVimeoVideoQualityHigh
}IGVimeoVideoQuality;

@class  IGVimeoVideo;
@protocol  IGVimeoExtractorDelegate;

typedef void (^completionHandler) (IGVimeoVideo * _Nullable  video, NSError * _Nullable error);

@interface IGVimeoVideo : NSObject
@property (nonatomic, copy) NSString* _Nonnull title;
@property (nonatomic, copy) NSURL* _Nonnull videoURL;
@property (nonatomic, copy) NSURL * _Nonnull  thumbnailURL;
@property (nonatomic, assign) IGVimeoVideoQuality quality;

+(instancetype _Nonnull) videoWithTitle:(NSString* _Nonnull)title videoURL:(NSURL* _Nonnull)videoURL thumbnailURL:(NSURL* _Nonnull)thumbnailURL quality:(IGVimeoVideoQuality)quality;
-(instancetype _Nonnull) initWithTitle:(NSString* _Nonnull)title videoURL:(NSURL* _Nonnull)videoURL thumbnailURL:(NSURL* _Nonnull)thumbnailURL quality:(IGVimeoVideoQuality)quality;
@end

@interface IGVimeoExtractor : NSObject <NSURLConnectionDelegate>

@property (nonatomic, readonly) BOOL running;
@property (nonatomic, readonly) IGVimeoVideoQuality quality;
@property (nonatomic, readonly) NSString* _Nonnull referer;
@property (strong, nonatomic, readonly) NSURL * _Nullable vimeoURL;

@property (unsafe_unretained, nonatomic) id<IGVimeoExtractorDelegate> _Nullable delegate;

+ (void)fetchVideoURLFromURL:(NSString * _Nonnull)videoURL quality:(IGVimeoVideoQuality)quality completionHandler:(completionHandler _Nullable)handler;
+ (void)fetchVideoURLFromID:(NSString * _Nonnull)videoURL quality:(IGVimeoVideoQuality)quality completionHandler:(completionHandler _Nullable)handler;
+ (void)fetchVideoURLFromURL:(NSString * _Nonnull)videoURL quality:(IGVimeoVideoQuality)quality referer:(NSString * _Nullable)referer completionHandler:(completionHandler _Nullable)handler;
+ (void)fetchVideoURLFromID:(NSString * _Nonnull)videoURL quality:(IGVimeoVideoQuality)quality referer:(NSString * _Nullable)referer completionHandler:(completionHandler _Nullable)handler;

- (instancetype _Nonnull)initWithURL:(NSString * _Nonnull)videoURL quality:(IGVimeoVideoQuality)quality;
- (instancetype _Nonnull)initWithID:(NSString * _Nonnull)videoID quality:(IGVimeoVideoQuality)quality;
- (instancetype _Nonnull)initWithURL:(NSString * _Nonnull)videoURL quality:(IGVimeoVideoQuality)quality referer:(NSString * _Nullable)referer;
- (instancetype _Nonnull)initWithID:(NSString * _Nonnull)videoID quality:(IGVimeoVideoQuality)quality referer:(NSString * _Nullable)referer;

- (void)start;

@end

@protocol IGVimeoExtractorDelegate <NSObject>

- (void)vimeoExtractor:(IGVimeoExtractor * _Nonnull)extractor didSuccessfullyExtractVimeoURL:(NSURL * _Nullable)videoURL withQuality:(IGVimeoVideoQuality)quality;
- (void)vimeoExtractor:(IGVimeoExtractor * _Nonnull)extractor failedExtractingVimeoURLWithError:(NSError * _Nullable)error;

@end
