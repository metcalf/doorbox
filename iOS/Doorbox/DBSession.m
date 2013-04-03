//
//  DBSession.m
//  Doorbox
//
//  Created by Andrew Metcalf on 3/14/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import "DBSession.h"
#import "BPXLUUIDHandler.h"

static DBSession *g_dbActiveSession = nil;

@interface DBSession ()

// TODO: Be careful there are thread-safety issues here
@property(readwrite, copy, nonatomic) DBSessionStateHandler stateHandler;

@end

@implementation DBSession

- (id) init {
    if (self = [super init]){
        _state = DBSessionStateCreated;
        
        NSDictionary *responseDict = @{
                                       @"state": [NSNumber numberWithInt:DBDoorUnconfigured],
                                       };
        
        [DBSession activeSession].mockDoorphone = [[DBDoorphone alloc] initWithResponseDictionary:responseDict];
        
        
    }
    return self;
}

- (void) authFacebookWithAllowLoginUI:(BOOL)allowLoginUI
                  sessionStateChanged:(DBSessionStateHandler)handler {
    [self setStateHandler:handler];
    FBSession *fbSession = [FBSession activeSession];
    if(!fbSession.isOpen){
        BOOL fbResult = [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:allowLoginUI
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          [self handleFacebookStateChanged:session state:state error:error];
                                      }];
        if(!(fbResult || allowLoginUI)){ // Couldn't start auth
            return; 
        }
        if(allowLoginUI && !fbResult){ // Auth started asyncronously
            [self transitionToState:DBSessionStateAuth];
            return;
        }
    }
    // Authed or using already open session
    [self transitionToState:DBSessionStateAuth];
    [self openWithFacebookSession:fbSession];
}

- (void) openWithFacebookSession:(FBSession*)fbSession {
    if(!fbSession.isOpen){
        // TODO: raise an error
    }
    
    [self transitionToState:DBSessionStateOpening];
    /*
     Make a request to initiate a session
     Passes:
     Facebook access token
     Unique device UUID stored in NSUserDefaults
     Auth api returns a DB access token
     */
    [BPXLUUIDHandler UUID];
    _accessToken = @"TBD";
    [self transitionToState:DBSessionStateOpen];
}

- (void) handleFacebookStateChanged:(FBSession *)session
                              state:(FBSessionState)state
                              error:(NSError *)error {
    // TODO: Would prefer to only call the state handler once on an error
    // not on both error and subsequent transition (if any)
    if(error && self.stateHandler){
        self.stateHandler(self, nil, error);
    }
    
    switch (state) {
        case FBSessionStateOpen: {
            if(self.state == DBSessionStateAuth){
                [self openWithFacebookSession:session];
            }
            }
            break;
        case FBSessionStateClosed: {
            [self close];
            }
            break;
        case FBSessionStateClosedLoginFailed: {
            [self close];
            }
            break;
        default:
            break;
    }
}

- (void) transitionToState:(DBSessionState) state {
    _state = state;
    if(self.stateHandler != nil){
        self.stateHandler(self, state, nil);
    }
}

- (void) setStateHandler:(DBSessionStateHandler)handler {
    if (handler != nil) {
        if (self.stateHandler == nil) {
            self.stateHandler = handler;
        } else if (self.stateHandler != handler) {
            //Note blocks are not value comparable, so this can intentionally result in false positives.
            NSLog(@"INFO: A different session open completion handler was supplied when one already existed.");
        }
    }
}

- (void) close {
    /* TODO: Add any closing logic */
    [self transitionToState:DBSessionStateClosed];
    if (g_dbActiveSession == self) {
        g_dbActiveSession = nil;
    }
}

+ (DBSession*) activeSession {
    return g_dbActiveSession;
}

+ (void) setActiveSession:(DBSession*)session {
    if (session != g_dbActiveSession){
        [g_dbActiveSession close];
        g_dbActiveSession = session;
    }
}

+ (void) openWithFacebookAllowLoginUI:(BOOL)allowLoginUI
                  sessionStateChanged:(DBSessionStateHandler)handler {
    DBSession *session = [[DBSession alloc] init];
    [session authFacebookWithAllowLoginUI:allowLoginUI sessionStateChanged:handler];
    
}


@end
