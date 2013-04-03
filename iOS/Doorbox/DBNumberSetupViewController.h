//
//  DBNumberSetupViewController.h
//  Doorbox
//
//  Created by Andrew Metcalf on 3/28/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface DBNumberSetupViewController : UIViewController

- (id)initWithNibName:(NSString *)nibNameorNil
               bundle:(NSBundle *)nibBundleOrNil
             location:(CLLocationCoordinate2D)location
               radius:(CLLocationDistance)radius;

@end
