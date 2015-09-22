//
//  IGVimeoExtractor.m
//  IGVimeoExtractor
//
//  Created by Louis Larpin on 18/02/13.
//

#import "IGVimeoExtractor.h"

NSString *const IGVimeoPlayerConfigURL = @"https://player.vimeo.com/video/%@/config";
NSString *const IGVimeoExtractorErrorDomain = @"IGVimeoExtractorErrorDomain";

@implementation IGVimeoVideo : NSObject

+(instancetype) videoWithTitle:(NSString*)title videoURL:(NSURL*)videoURL thumbnailURL:(NSURL*)thumbnailURL quality:(IGVimeoVideoQuality)quality
{
    return [[self alloc] initWithTitle:title videoURL:videoURL thumbnailURL:thumbnailURL quality:quality];
}

-(instancetype) initWithTitle:(NSString*)title videoURL:(NSURL*)videoURL thumbnailURL:(NSURL*)thumbnailURL quality:(IGVimeoVideoQuality)quality
{
    IGVimeoVideo* video = [super init];
    video.title = title;
    video.videoURL = videoURL;
    video.thumbnailURL = thumbnailURL;
    video.quality = quality;
    return video;
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"<IGVimeoVideo title=%@ quality=%@", self.title, @(self.quality)];
}

@end

@interface IGVimeoExtractor ()
@property (copy, nonatomic) completionHandler completionHandler;
- (void)extractorFailedWithMessage:(NSString*)message errorCode:(int)code;
@end

@implementation IGVimeoExtractor

+ (void)fetchVideoURLFromURL:(NSString *)videoURL referer:(NSString *)referer completionHandler:(completionHandler)handler
{
    IGVimeoExtractor *extractor = [[IGVimeoExtractor alloc] initWithURL:videoURL referer:referer];
    extractor.completionHandler = handler;
    [extractor start];
}

+ (void)fetchVideoURLFromID:(NSString *)videoID referer:(NSString *)referer completionHandler:(completionHandler)handler
{
    IGVimeoExtractor *extractor = [[IGVimeoExtractor alloc] initWithID:videoID referer:referer];
    extractor.completionHandler = handler;
    [extractor start];
}

+ (void)fetchVideoURLFromURL:(NSString *)videoURL completionHandler:(completionHandler)handler
{
    return [IGVimeoExtractor fetchVideoURLFromURL:videoURL referer:nil completionHandler:handler];
}

+ (void)fetchVideoURLFromID:(NSString *)videoID completionHandler:(completionHandler)handler
{
    return [IGVimeoExtractor fetchVideoURLFromID:videoID referer:nil completionHandler:handler];}

#pragma mark - Constructors

- (id)initWithID:(NSString *)videoID referer:(NSString *)referer
{
    self = [super init];
    if (self) {
        _vimeoURL = [NSURL URLWithString:[NSString stringWithFormat:IGVimeoPlayerConfigURL, videoID]];
        _referer = referer;
    }
    return self;
}

- (id)initWithURL:(NSString *)videoURL referer:(NSString *)referer
{
    NSString *videoID = [[videoURL componentsSeparatedByString:@"/"] lastObject];
    return [self initWithID:videoID referer:referer];
}

- (id)initWithID:(NSString *)videoID
{
    return [self initWithID:videoID referer:nil];
}

- (id)initWithURL:(NSString *)videoURL {
    return [self initWithURL:videoURL referer:nil];
}

#pragma mark - Public

- (void)start
{
    if (!(self.completionHandler) || !self.vimeoURL) {
        [self extractorFailedWithMessage:@"block or URL not specified" errorCode:IGVimeoExtractorErrorCodeNotInitialized];
        return;
    }

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.vimeoURL];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    if (self.referer) {
        [request setValue:self.referer forHTTPHeaderField:@"Referer"];
    }

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            self.completionHandler(nil, error);
            return;
        }

        NSError* jsonError;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        if (jsonError) {
            [self extractorFailedWithMessage:@"Invalid video indentifier" errorCode:IGVimeoExtractorErrorInvalidIdentifier];
            return;
        }
        
        NSDictionary *filesInfo = [jsonData valueForKeyPath:@"request.files.h264"];
        if (!filesInfo) {
            [self extractorFailedWithMessage:@"Unsupported video codec" errorCode:IGVimeoExtractorErrorUnsupportedCodec];
            return;
        }
        
        NSURL *thumbnailURL = [NSURL URLWithString:[jsonData valueForKeyPath:@"video.thumbs.base"]];
        NSString* title = [jsonData valueForKeyPath:@"video.title"];
        
        NSDictionary *videoInfo;
        NSMutableArray* videos = [NSMutableArray array];
        IGVimeoVideoQuality videoQuality = IGVimeoVideoQualityHigh;
        NSArray* qualityKeys = @[ @"mobile", @"sd", @"hd" ];
        do {
            videoInfo = [filesInfo objectForKey:qualityKeys[videoQuality]];
            
            NSURL *videoURL = [NSURL URLWithString:[videoInfo objectForKey:@"url"]];
            if (videoURL) {
                IGVimeoVideo* video = [IGVimeoVideo videoWithTitle:title videoURL:videoURL thumbnailURL:thumbnailURL quality:videoQuality];
                [videos addObject:video];
            }
            videoQuality--;
        } while (videoQuality >= IGVimeoVideoQualityLow && videoQuality <= IGVimeoVideoQualityHigh);
        
        if ([videos count] > 0) {
            self.completionHandler(videos, nil);
        } else {
            [self extractorFailedWithMessage:@"Video not found" errorCode:IGVimeoExtractorErrorUnexpected];
        }
    }] resume];
}

# pragma mark - Private

- (void)extractorFailedWithMessage:(NSString*)message errorCode:(int)code {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:IGVimeoExtractorErrorDomain code:code userInfo:userInfo];
    self.completionHandler(nil, error);
}

@end
