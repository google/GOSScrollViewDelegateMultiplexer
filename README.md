# MDFScrollViewDelegateMultiplexer
[![Build Status](https://travis-ci.org/material-foundation/MDFScrollViewDelegateMultiplexer.svg?branch=master)](https://travis-ci.org/material-foundation/MDFScrollViewDelegateMultiplexer)

This class acts as a proxy object for `UIScrollViewDelegate` events and forwards all received
events to an ordered list of registered observers.

## Installation

### Requirements

- Xcode 7.0 or higher.
- iOS SDK version 7.0 or higher.

### Installation with CocoaPods

To add this component to your Xcode project using CocoaPods, add the following to your `Podfile`:

~~~ bash
pod 'MDFScrollViewDelegateMultiplexer'
~~~

Then, run the following command:

~~~ bash
pod install
~~~

- - -

## Overview

When a `UIScrollViewDelegate` method invocation is received by the multiplexer, the multiplexer
forwards the invocation to each observer in order of registration.

If the scroll view method signature has a return value, after all delegate method invocations,
the return value will be provided by the first observing delegate that responded. If no
observers implement the method, a default return value will be used.

However, if a combiner is set and the receiving class conforms to the
`MDFScrollViewDelegateCombining` protocol, then the receiving class can designate which result
value to return via the use of the optional protocol methods.

- - -


## Usage

```objectivec
#import "MDFScrollViewDelegateMultiplexer.h"

_multiplexer = [[MDFScrollViewDelegateMultiplexer alloc] init];
myScrollView.delegate = _multiplexer;
[_multiplexer addObservingDelegate:myControl];
[_multiplexer addObservingDelegate:anotherControl];
```

## Using the `MDFScrollViewDelegateCombining` protocol

First conform to the `MDFScrollViewDelegateCombining` protocol:

```objectivec
@interface MyViewController () <MDFScrollViewDelegateCombining>
@end

[_multiplexer setCombiner:self];
```

Handle one of the `UIScrollViewDelegate` protocol methods that return a value:

```objectivec
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return myZoomingView;
}
```

And finally return the desired observer's results from the combiner method:

```objectivec
- (UIView *)scrollViewDelegateMultiplexer:(MDFScrollViewDelegateMultiplexer *)multiplexer
                viewForZoomingWithResults:(NSPointerArray *)results
                  fromRespondingObservers:(NSArray *)respondingObservers {
  // Lets return the results from the oberserver which is equal to self.
  if (respondingObservers[0] == self) {
    return [results pointerAtIndex:0];
  }
  return nil;
}
```
