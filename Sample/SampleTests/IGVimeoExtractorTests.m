//
//  IGVimeoExtractorTests.m
//  Sample
//
//  Created by Francis Chong on 8/12/2015.
//  Copyright © 2015 Louis Larpin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IGVimeoExtractor.h"

@interface IGVimeoExtractorTests : XCTestCase
@end

@implementation IGVimeoExtractorTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFetchVideoURLFromURL {
    XCTestExpectation* downloaded = [self expectationWithDescription:@"Fetch from Vimeo"];
    [IGVimeoExtractor fetchVideoURLFromURL:@"https://vimeo.com/147432511" completionHandler:^(NSArray<IGVimeoVideo *> * _Nullable videos, NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Error while downloading video: %@", error);
            return;
        }

        XCTAssert(videos.count == 3, @"should have 3 video");
        [videos enumerateObjectsUsingBlock:^(IGVimeoVideo * _Nonnull video, NSUInteger idx, BOOL * _Nonnull stop) {
            XCTAssertNotNil(video);
            XCTAssertNotNil(video.videoURL);
            XCTAssertNotNil(video.thumbnailURL);
        }];
        [downloaded fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"error occurred: %@", error);
        }
    }];
}

@end
