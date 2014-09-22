//
//  IGVimeoExtractor.m
//  IGVimeoExtractor
//
//  Created by Louis Larpin on 18/02/13.
//

#import "IGVimeoExtractor.h"

NSString *const IGVimeoPlayerConfigURL = @"http://player.vimeo.com/video/%@/config";
NSString *const IGVimeoExtractorErrorDomain = @"IGVimeoExtractorErrorDomain";

@interface IGVimeoExtractor ()

@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *buffer;
@property (copy, nonatomic) completionHandler completionHandler;

- (void)extractorFailedWithMessage:(NSString*)message errorCode:(int)code;

@end

@implementation IGVimeoExtractor

+ (void)fetchVideoURLFromURL:(NSString *)videoURL quality:(IGVimeoVideoQuality)quality referer:(NSString *)referer completionHandler:(completionHandler)handler
{
    IGVimeoExtractor *extractor = [[IGVimeoExtractor alloc] initWithURL:videoURL quality:quality referer:referer];
    extractor.completionHandler = handler;
    [extractor start];
}

+ (void)fetchVideoURLFromID:(NSString *)videoID quality:(IGVimeoVideoQuality)quality referer:(NSString *)referer completionHandler:(completionHandler)handler
{
    IGVimeoExtractor *extractor = [[IGVimeoExtractor alloc] initWithID:videoID quality:quality referer:referer];
    extractor.completionHandler = handler;
    [extractor start];
}
+ (void)fetchVideoURLFromURL:(NSString *)videoURL quality:(IGVimeoVideoQuality)quality completionHandler:(completionHandler)handler
{
    return [IGVimeoExtractor fetchVideoURLFromURL:videoURL quality:quality referer:nil completionHandler:handler];
}

+ (void)fetchVideoURLFromID:(NSString *)videoID quality:(IGVimeoVideoQuality)quality completionHandler:(completionHandler)handler
{
    return [IGVimeoExtractor fetchVideoURLFromID:videoID quality:quality referer:nil completionHandler:handler];}

#pragma mark - Constructors

- (id)initWithID:(NSString *)videoID quality:(IGVimeoVideoQuality)quality referer:(NSString *)referer
{
    self = [super init];
    if (self) {
        _vimeoURL = [NSURL URLWithString:[NSString stringWithFormat:IGVimeoPlayerConfigURL, videoID]];
        _quality = quality;
        _referer = referer;
        _running = NO;
    }
    return self;
}

- (id)initWithURL:(NSString *)videoURL quality:(IGVimeoVideoQuality)quality referer:(NSString *)referer
{
    NSString *videoID = [[videoURL componentsSeparatedByString:@"/"] lastObject];
    return [self initWithID:videoID quality:quality referer:referer];
}

- (id)initWithID:(NSString *)videoID quality:(IGVimeoVideoQuality)quality
{
    return [self initWithID:videoID quality:quality referer:nil];
}

- (id)initWithURL:(NSString *)videoURL quality:(IGVimeoVideoQuality)quality {
    return [self initWithURL:videoURL quality:quality referer:nil];
}

- (void)dealloc
{
    [self.connection cancel];
    self.connection = nil;
    self.buffer = nil;
    self.delegate = nil;
}

#pragma mark - Public

- (void)start
{
    if (!(self.delegate || self.completionHandler) || !self.vimeoURL) {
        [self extractorFailedWithMessage:@"Delegate, block or URL not specified" errorCode:IGVimeoExtractorErrorCodeNotInitialized];
        return;
    }
    if (self.running) {
        [self extractorFailedWithMessage:@"Already in progress" errorCode:IGVimeoExtractorErrorCodeNotInitialized];
        return;
    }

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.vimeoURL];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    if (self.referer) {
        [request setValue:self.referer forHTTPHeaderField:@"Referer"];
    }

    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    _running = YES;
}

# pragma mark - Private

- (void)extractorFailedWithMessage:(NSString*)message errorCode:(int)code {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:IGVimeoExtractorErrorDomain code:code userInfo:userInfo];

    if (self.completionHandler) {
        self.completionHandler(nil, nil, error, self.quality);
    }
    else if ([self.delegate respondsToSelector:@selector(vimeoExtractor:failedExtractingVimeoURLWithError:)]) {
        [self.delegate vimeoExtractor:self failedExtractingVimeoURLWithError:error];
    }
    _running = NO;
}

#pragma mark - NSURLConnectionDelegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSInteger statusCode = [httpResponse statusCode];
    if (statusCode != 200) {
        [self extractorFailedWithMessage:@"Invalid video indentifier" errorCode:IGVimeoExtractorErrorInvalidIdentifier];
        [connection cancel];
    }

    NSUInteger capacity = (response.expectedContentLength != NSURLResponseUnknownLength) ? (uint)response.expectedContentLength : 0;
    self.buffer = [[NSMutableData alloc] initWithCapacity:capacity];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:self.buffer options:NSJSONReadingAllowFragments error:&error];

    if (error) {
        [self extractorFailedWithMessage:@"Invalid video indentifier" errorCode:IGVimeoExtractorErrorInvalidIdentifier];
        return;
    }

    NSDictionary *filesInfo = [jsonData valueForKeyPath:@"request.files.h264"];
    if (!filesInfo) {
        [self extractorFailedWithMessage:@"Unsupported video codec" errorCode:IGVimeoExtractorErrorUnsupportedCodec];
        return;
    }

    NSDictionary *videoInfo;
    IGVimeoVideoQuality videoQuality = self.quality;
    do {
        videoInfo = [filesInfo objectForKey:@[ @"mobile", @"sd", @"hd" ][videoQuality]];
        videoQuality--;
    } while (!videoInfo && videoQuality >= IGVimeoVideoQualityLow);

    if (!videoInfo) {
        [self extractorFailedWithMessage:@"Unavailable video quality" errorCode:IGVimeoExtractorErrorUnavailableQuality];
        return;
    }

    NSURL *fileURL = [NSURL URLWithString:[videoInfo objectForKey:@"url"]];
    NSString* title = [jsonData valueForKeyPath:@"video.title"];
    if (self.completionHandler) {
        self.completionHandler(fileURL, title, nil, videoQuality);
    }
    else if ([self.delegate respondsToSelector:@selector(vimeoExtractor:didSuccessfullyExtractVimeoURL:withQuality:)]) {
        [self.delegate vimeoExtractor:self didSuccessfullyExtractVimeoURL:fileURL withQuality:videoQuality];
    }

    _running = NO;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self extractorFailedWithMessage:[error localizedDescription] errorCode:IGVimeoExtractorErrorInvalidIdentifier];
}

@end
