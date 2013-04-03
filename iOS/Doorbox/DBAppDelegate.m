//
//  DBAppDelegate.m
//  Doorbox
//
//  Created by Andrew Metcalf on 2/6/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import "DBAppDelegate.h"

#import "DBSession.h"
#import "DBViewController.h"
#import "DBLoginViewController.h"

NSString *const DBSessionStateChangedNotification = @"com.throughawall.doorbox:DBSessionStateChangedNotification";

@interface DBAppDelegate ()

@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) DBViewController *mainViewController;
@property (strong, nonatomic) DBLoginViewController* loginViewController;

@end

@implementation DBAppDelegate

- (void)createAndPresentLoginView {
    if (self.loginViewController == nil) {
        self.loginViewController = [[DBLoginViewController alloc]
                                    initWithNibName:@"DBLoginViewController"
                                    bundle:nil];
        UIViewController *topViewController = [self.navController topViewController];
        [topViewController presentModalViewController:self.loginViewController animated:NO];
    }
}

- (void)showLoginView {
    if (self.loginViewController == nil) {
        [self createAndPresentLoginView];
    } else {
        [self.loginViewController loginFailed];
    }
}

- (void)sessionStateChanged:(DBSession *)session
                      state:(DBSessionState)state
                      error:(NSError *)error
{
    // FBSample logic
    // Any time the session is closed, we want to display the login controller (the user
    // cannot use the application unless they are logged in to Facebook). When the session
    // is opened successfully, hide the login controller and show the main UI.
    switch (state) {
        case DBSessionStateOpen: {
            // TODO: After login
            [self.mainViewController postLoginFunction];
            if (self.loginViewController != nil) {
                UIViewController *topViewController = [self.navController topViewController];
                [topViewController dismissModalViewControllerAnimated:YES];
                self.loginViewController = nil;
            }
            // FBSample logic
            // Pre-fetch and cache the friends for the friend picker as soon as possible to improve
            // responsiveness when the user tags their friends.
            //FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
            //[cacheDescriptor prefetchAndCacheForSession:session];
        }
            break;
        case DBSessionStateOpening: {
            // TODO: Show the opening progress with some type of modal
        }
            break;
        case DBSessionStateClosed: {
            // Once the user has logged out, we want them to be looking at the root view.
            if(self.navController.visibleViewController != self.loginViewController){
                UIViewController *topViewController = [self.navController topViewController];
                UIViewController *modalViewController = [topViewController modalViewController];
                if (modalViewController != nil) {
                    [topViewController dismissModalViewControllerAnimated:NO];
                }
                [self.navController popToRootViewControllerAnimated:NO];
            }
            [FBSession.activeSession closeAndClearTokenInformation];
            [self performSelector:@selector(showLoginView)
                       withObject:nil
                       afterDelay:0.5f];
        }
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DBSessionStateChangedNotification
                                                        object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error: %@",
                                                                     [DBAppDelegate FBErrorCodeDescription:error.code]]
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    return [FBSession openActiveSessionWithReadPermissions:nil
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                             [self sessionStateChanged:session state:state error:error];
                                         }];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // We need to handle URLs by passing them to FBSession in order for SSO authentication
    // to work.
    return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.mainViewController = [[DBViewController alloc] initWithNibName:@"DBViewController" bundle:nil];
    self.navController = [[UINavigationController alloc]
                          initWithRootViewController:self.mainViewController];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    if (![self openSessionWithAllowLoginUI:NO]) {
        // No? Display the login page.
        [self showLoginView];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
    [self.mainViewController refreshDoorphone];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // if the app is going away, we close the session object; this is a good idea because
    // things may be hanging off the session, that need releasing (completion block, etc.) and
    // other components in the app may be awaiting close notification in order to do cleanup
    [FBSession.activeSession close];
}

+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code {
    switch(code){
        case FBErrorInvalid :{
            return @"FBErrorInvalid";
        }
        case FBErrorOperationCancelled:{
            return @"FBErrorOperationCancelled";
        }
        case FBErrorLoginFailedOrCancelled:{
            return @"FBErrorLoginFailedOrCancelled";
        }
        case FBErrorRequestConnectionApi:{
            return @"FBErrorRequestConnectionApi";
        }case FBErrorProtocolMismatch:{
            return @"FBErrorProtocolMismatch";
        }
        case FBErrorHTTPError:{
            return @"FBErrorHTTPError";
        }
        case FBErrorNonTextMimeTypeReturned:{
            return @"FBErrorNonTextMimeTypeReturned";
        }
        case FBErrorNativeDialog:{
            return @"FBErrorNativeDialog";
        }
        default:
            return @"[Unknown]";
    }
}

@end
