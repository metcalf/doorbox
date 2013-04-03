//
//  DBLocationSetupViewController.h
//  Doorbox
//
//  Created by Andrew Metcalf on 3/14/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

double const MIN_MAP_SPAN_METERS;
double const MIN_CIRCLE_RADIUS_METERS;
double const DEFAULT_CIRCLE_RADIUS_METERS;
double const MAX_CIRCLE_RADIUS_METERS;
double const MAX_OVERLAY_LATITUDE_SPAN;

@interface DBLocationSetupViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate>

@end
