//
//  print2serverTests.m
//  print2serverTests
//
//  Created by gj on 18/7/17.
//
//

#import <XCTest/XCTest.h>

extern int create_dir(char *dirname, int nolog);


@interface print2serverTests : XCTestCase

@end

@implementation print2serverTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    //XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        //for (NSInteger index = 0; index < 10000; index ++) {
        //    NSLog(@"%ld",index);
        //}
    }];
}

@end
