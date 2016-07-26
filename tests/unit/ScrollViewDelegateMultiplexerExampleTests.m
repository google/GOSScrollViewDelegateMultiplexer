/*
 Copyright 2015-present Google Inc. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <XCTest/XCTest.h>

#import "MDFScrollViewDelegateMultiplexer.h"

static NSString *const kScrollViewDidScroll = @"scrollViewDidScroll";

#pragma mark - Simple observer object

/** Simple object that conforms to UIScrollViewDelegate protocol. */
@interface ScrollObservingObject : UIView <UIScrollViewDelegate>
@property(nonatomic) BOOL hasRecievedScrollViewDidScroll;

@end

@implementation ScrollObservingObject

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  _hasRecievedScrollViewDidScroll = YES;
}

@end

@interface ScrollViewDelegateMultiplexerExampleTests : XCTestCase
@end

@implementation ScrollViewDelegateMultiplexerExampleTests {
  UIScrollView *_scrollView;
  ScrollObservingObject *_observingObject;
  MDFScrollViewDelegateMultiplexer *_multiplexer;
  XCTestExpectation *_expectation;
  XCTestExpectation *_observerExpectation;
}

- (void)setUp {
  [super setUp];
  _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 100, 10)];
  _scrollView.contentSize = CGSizeMake(200, 10);
}

- (void)tearDown {
  [super tearDown];
}

#pragma mark - Tests

- (void)testWithoutMultiplexer {
  // Given
  ScrollObservingObject *scrollObserver = [[ScrollObservingObject alloc] init];
  _scrollView.delegate = scrollObserver;

  // When
  [_scrollView setContentOffset:CGPointMake(50, 0) animated:YES];

  // Then
  XCTAssertTrue(scrollObserver.hasRecievedScrollViewDidScroll);
}

- (void)testMuliplexerSingleDelegate {
  // Given
  ScrollObservingObject *scrollObserver = [[ScrollObservingObject alloc] init];
  _multiplexer = [[MDFScrollViewDelegateMultiplexer alloc] init];
  [_multiplexer addObservingDelegate:scrollObserver];
  _scrollView.delegate = _multiplexer;

  // When
  [_scrollView setContentOffset:CGPointMake(50, 0) animated:YES];

  // Then
  XCTAssertTrue(scrollObserver.hasRecievedScrollViewDidScroll);
}

- (void)testMuliplexerMultipleDelegate {
  // Given
  _multiplexer = [[MDFScrollViewDelegateMultiplexer alloc] init];
  _scrollView.delegate = _multiplexer;

  ScrollObservingObject *scrollObserver = [[ScrollObservingObject alloc] init];
  [_multiplexer addObservingDelegate:scrollObserver];
  ScrollObservingObject *secondScrollObserver = [[ScrollObservingObject alloc] init];
  [_multiplexer addObservingDelegate:secondScrollObserver];

  // When
  [_scrollView setContentOffset:CGPointMake(50, 0) animated:YES];

  // Then
  XCTAssertTrue(scrollObserver.hasRecievedScrollViewDidScroll);
  XCTAssertTrue(secondScrollObserver.hasRecievedScrollViewDidScroll);
}

- (void)testRemoveDelegates{
  // Given
  ScrollObservingObject *scrollObserver = [[ScrollObservingObject alloc] init];
  _multiplexer = [[MDFScrollViewDelegateMultiplexer alloc] init];
  [_multiplexer addObservingDelegate:scrollObserver];
  _scrollView.delegate = _multiplexer;

  // When
  [_multiplexer removeObservingDelegate:scrollObserver];
  [_scrollView setContentOffset:CGPointMake(50, 0) animated:YES];

  // Then
  XCTAssertFalse(scrollObserver.hasRecievedScrollViewDidScroll);
}

- (void)testRemoveMultipleDelegates{
  // Given
  _multiplexer = [[MDFScrollViewDelegateMultiplexer alloc] init];
  _scrollView.delegate = _multiplexer;

  ScrollObservingObject *scrollObserver = [[ScrollObservingObject alloc] init];
  [_multiplexer addObservingDelegate:scrollObserver];
  ScrollObservingObject *secondScrollObserver = [[ScrollObservingObject alloc] init];
  [_multiplexer addObservingDelegate:secondScrollObserver];

  // When
  [_multiplexer removeObservingDelegate:secondScrollObserver];
  [_multiplexer removeObservingDelegate:scrollObserver];
  [_scrollView setContentOffset:CGPointMake(50, 0) animated:YES];

  // Then
  XCTAssertFalse(scrollObserver.hasRecievedScrollViewDidScroll);
  XCTAssertFalse(secondScrollObserver.hasRecievedScrollViewDidScroll);
}

- (void)testRemoveMultipleDelegatesOfTheSameObserver{
  // Given
  _multiplexer = [[MDFScrollViewDelegateMultiplexer alloc] init];
  _scrollView.delegate = _multiplexer;

  ScrollObservingObject *scrollObserver = [[ScrollObservingObject alloc] init];
  [_multiplexer addObservingDelegate:scrollObserver];
  [_multiplexer addObservingDelegate:scrollObserver];

  // When
  [_multiplexer removeObservingDelegate:scrollObserver];
  [_scrollView setContentOffset:CGPointMake(50, 0) animated:YES];

  // Then
  XCTAssertFalse(scrollObserver.hasRecievedScrollViewDidScroll);
}

@end
