//
//  DBDoorphoneSetupViewController.h
//  Doorbox
//
//  Created by Andrew Metcalf on 3/29/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DBDoorphoneSetupViewController : UITableViewController

- (id)initWithStyle:(UITableViewStyle)style
           location:(CLLocationCoordinate2D)location
             radius:(CLLocationDistance)radius;

@end
