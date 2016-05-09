/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBApplication.h"

#import "FBApplicationProcessProxy.h"
#import "XCUIApplication.h"
#import "XCUIApplicationImpl.h"
#import "XCUIApplicationProcess.h"

#import "XCAXClient_iOS.h"
#import "XCAccessibilityElement.h"
#import "XCUIElement.h"
#import "XCUIElementQuery.h"

@implementation FBApplication

+ (instancetype)activeApplication
{
  XCAccessibilityElement *activeApplicationElement = [[[XCAXClient_iOS sharedClient] activeApplications] firstObject];
  if (!activeApplicationElement) {
    return nil;
  }
  FBApplication *application = [FBApplication appWithPID:activeApplicationElement.processIdentifier];
  [application query];
  [application resolve];
  return application;
}

- (void)launch
{
  if (!self.shouldWaitForQuiescence) {
    [self placeApplicationProxy];
  }
  [super launch];
}

- (void)_waitForQuiescence
{
  if (!self.shouldWaitForQuiescence) {
    return;
  }
  [super _waitForQuiescence];
}

- (void)placeApplicationProxy
{
  if (![self respondsToSelector:@selector(applicationImpl)]) {
    return;
  }
  XCUIApplicationImpl *appImpl = [self applicationImpl];
  if (![appImpl respondsToSelector:@selector(currentProcess)]) {
    return;
  }
  appImpl.currentProcess = (XCUIApplicationProcess *)[FBApplicationProcessProxy proxyWithApplicationProcess:appImpl.currentProcess];
}

@end
