//
//  DBAppDelegate.h
//  Doorbox
//
//  Created by Andrew Metcalf on 2/6/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>


@class DBViewController;

@interface DBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code;

@end
