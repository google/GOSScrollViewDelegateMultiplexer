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

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "SVDMTypicalUseViewController.h"

#import "GOSScrollViewDelegateMultiplexer.h"
#import "ObservingPageControl.h"

#define RGBCOLOR(r, g, b) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:1]
#define HEXCOLOR(hex) RGBCOLOR((((hex) >> 16) & 0xFF), (((hex) >> 8) & 0xFF), ((hex)&0xFF))

@interface SVDMTypicalUseViewController () <GOSScrollViewDelegateCombining>
@end

@implementation SVDMTypicalUseViewController {
  UIScrollView *_scrollView;
  UIPageControl *_pageControl;
  NSArray *_pageColors;
  GOSScrollViewDelegateMultiplexer *_multiplexer;
}

+ (NSArray *)catalogBreadcrumbs {
  return @[ @"ScrollViewDelegate Multiplexer", @"Typical use" ];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  CGFloat boundsWidth = CGRectGetWidth(self.view.bounds);
  CGFloat boundsHeight = CGRectGetHeight(self.view.bounds);

  _pageColors = @[ HEXCOLOR(0x81D4FA), HEXCOLOR(0x80CBC4), HEXCOLOR(0xFFCC80) ];

  // Scroll view configuration

  _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
  _scrollView.pagingEnabled = YES;
  _scrollView.contentSize = CGSizeMake(boundsWidth * _pageColors.count, boundsHeight);
  _scrollView.minimumZoomScale = 0.5;
  _scrollView.maximumZoomScale = 1.5;

  // Add pages to scrollView.
  for (NSInteger i = 0; i < _pageColors.count; i++) {
    CGRect pageFrame = CGRectOffset(self.view.bounds, i * boundsWidth, 0);
    UIView *page = [[UIView alloc] initWithFrame:pageFrame];
    page.backgroundColor = _pageColors[i];
    [_scrollView addSubview:page];

    UILabel *pageTitle = [[UILabel alloc] initWithFrame:page.bounds];
    pageTitle.text = [NSString stringWithFormat:@"Page %zd", i + 1];
    pageTitle.font = [UIFont systemFontOfSize:50];
    pageTitle.textColor = [UIColor colorWithWhite:0 alpha:0.8];
    pageTitle.textAlignment = NSTextAlignmentCenter;
    pageTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [page addSubview:pageTitle];
  }

  // Page control configuration

  ObservingPageControl *pageControl = [[ObservingPageControl alloc] init];
  pageControl.numberOfPages = _pageColors.count;

  pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0 alpha:0.2];
  pageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0 alpha:0.8];

  CGSize pageControlSize = [pageControl sizeThatFits:self.view.bounds.size];
  // We want the page control to span the bottom of the screen.
  pageControlSize.width = self.view.bounds.size.width;
  pageControl.frame = CGRectMake(0,
                                 self.view.bounds.size.height - pageControlSize.height,
                                 self.view.bounds.size.width,
                                 pageControlSize.height);
  [pageControl addTarget:self
                  action:@selector(didChangePage:)
        forControlEvents:UIControlEventValueChanged];
  pageControl.defersCurrentPageDisplay = YES;
  pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
      | UIViewAutoresizingFlexibleLeftMargin
      | UIViewAutoresizingFlexibleRightMargin;
  _pageControl = pageControl;

  // Add subviews

  [self.view addSubview:_scrollView];
  [self.view addSubview:pageControl];

  // Create scrollView delegate multiplexer and register observers

  _multiplexer = [[GOSScrollViewDelegateMultiplexer alloc] init];
  _scrollView.delegate = _multiplexer;
  [_multiplexer addObservingDelegate:self];
  [_multiplexer addObservingDelegate:pageControl];
  [_multiplexer setCombiner:self];
}

#pragma mark - GOSScrollViewDelegateCombining

- (UIView *)scrollViewDelegateMultiplexer:(GOSScrollViewDelegateMultiplexer *)multiplexer
                viewForZoomingWithResults:(NSPointerArray *)results
                  fromRespondingObservers:(NSArray *)respondingObservers {
  // Lets return the results from the observer which is equal to self.
  if (respondingObservers[0] == self) {
    return [results pointerAtIndex:0];
  }
  return nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  NSLog(@"%@", NSStringFromSelector(_cmd));

  [_pageControl updateCurrentPageDisplay];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  // Since there are multiple observers, we will allow the combiner to return this page
  // as the zooming view.
  return scrollView.subviews[_pageControl.currentPage];
}

#pragma mark - User events

- (void)didChangePage:(UIPageControl *)sender {
  CGPoint offset = _scrollView.contentOffset;
  offset.x = sender.currentPage * _scrollView.bounds.size.width;
  [_scrollView setContentOffset:offset animated:YES];
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size
      withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  CGRect newBounds = CGRectMake(0, 0, size.width, size.height);
  // Adjust scrollView.
  _scrollView.frame = newBounds;
  _scrollView.contentSize = CGSizeMake(size.width * _pageColors.count, size.height);

  // Reset current page offset.
  CGPoint offset = _scrollView.contentOffset;
  offset.x = _pageControl.currentPage * size.width;
  [_scrollView setContentOffset:offset animated:YES];

  // Adjust pages.
  for (NSInteger i = 0; i < _pageColors.count; i++) {
    _scrollView.subviews[i].frame = CGRectOffset(newBounds, i * size.width, 0);
  }
}

@end
