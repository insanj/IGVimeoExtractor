//
//  IGVimeoExtractor.h
//  IGVimeoExtractor
//
//  Created by Louis Larpin on 18/02/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
    IGVimeoVideoQualityHigh,
    IGVimeoVideoQualityBest
}IGVimeoVideoQuality;

@class  IGVimeoVideo;
@protocol  IGVimeoExtractorDelegate;

typedef void (^completionHandler) (NSArray<IGVimeoVideo*>* _Nullable videos, NSError * _Nullable error);

@interface IGVimeoVideo : NSObject
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSURL* videoURL;
@property (nonatomic, copy) NSURL *  thumbnailURL;
@property (nonatomic, assign) IGVimeoVideoQuality quality;

+(instancetype) videoWithTitle:(NSString*)title videoURL:(NSURL*)videoURL thumbnailURL:(NSURL*)thumbnailURL quality:(IGVimeoVideoQuality)quality;
-(instancetype) initWithTitle:(NSString*)title videoURL:(NSURL*)videoURL thumbnailURL:(NSURL*)thumbnailURL quality:(IGVimeoVideoQuality)quality;
@end

@interface IGVimeoExtractor : NSObject <NSURLConnectionDelegate>

@property (nonatomic, readonly) NSString* _Nullable referer;
@property (strong, nonatomic, readonly) NSURL * _Nullable vimeoURL;

+ (void)fetchVideoURLFromURL:(NSString *)videoURL completionHandler:(completionHandler _Nonnull)handler;
+ (void)fetchVideoURLFromID:(NSString *)videoURL completionHandler:(completionHandler _Nonnull)handler;
+ (void)fetchVideoURLFromURL:(NSString *)videoURL referer:(NSString * _Nullable)referer completionHandler:(completionHandler)handler;
+ (void)fetchVideoURLFromID:(NSString *)videoURL referer:(NSString * _Nullable)referer completionHandler:(completionHandler)handler;

- (instancetype)initWithURL:(NSString *)videoURL;
- (instancetype)initWithID:(NSString *)videoID;
- (instancetype)initWithURL:(NSString *)videoURL referer:(NSString * _Nullable)referer;
- (instancetype)initWithID:(NSString *)videoID referer:(NSString * _Nullable)referer;

- (void)start;

@end

NS_ASSUME_NONNULL_END