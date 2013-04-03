//
//  DBSession.h
//  Doorbox
//
//  Created by Andrew Metcalf on 3/14/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "DBResult.h"

@class DBSession;

typedef enum {
    DBSessionStateCreated, // After init
    DBSessionStateAuth, // When auth is in progress (e.g. through Facebook)
    DBSessionStateOpening, // Requesting an access token
    DBSessionStateOpen, // Active
    DBSessionStateClosed, // Closed

} DBSessionState;

typedef void (^DBSessionStateHandler)(DBSession *session,
    DBSessionState state,
    NSError *error);

@interface DBSession : NSObject

@property (readonly) NSString *userName;
@property (readonly) DBSessionState state;
@property (readonly) NSString *accessToken;

@property DBDoorphone *mockDoorphone;

- (id) init;
- (void) close;
- (void) authFacebookWithAllowLoginUI:(BOOL)allowLoginUI
                  sessionStateChanged:(DBSessionStateHandler)handler ;

+ (DBSession*) activeSession;
+ (void) openWithFacebookAllowLoginUI:(BOOL)allowLoginUI
             sessionStateChanged:(DBSessionStateHandler)handler;

@end
