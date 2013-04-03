//
//  DBLocationSetupViewController.m
//  Doorbox
//
//  Created by Andrew Metcalf on 3/14/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import "DBLocationSetupViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "DBDoorphoneSetupViewController.h"

double const MIN_MAP_SPAN_METERS = 250;
double const MIN_CIRCLE_RADIUS_METERS = 30;
double const DEFAULT_CIRCLE_RADIUS_METERS = 50;
double const MAX_CIRCLE_RADIUS_METERS = 250;
double const MAX_OVERLAY_LATITUDE_SPAN = 0.5;

@interface DBLocationSetupViewController ()

@property CLLocationManager *locationManager;
@property BOOL followUser;
@property MKCircle *overlayCircle;
@property MKCircle *overlayDot;

@property (weak, nonatomic) IBOutlet UIButton *locateBtn;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation DBLocationSetupViewController

@synthesize mapView, locateBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Location";
    self.followUser = NO;
    
    [locateBtn addTarget:self
                  action:@selector(locatePress:)
        forControlEvents:UIControlEventTouchUpInside];
    locateBtn.layer.cornerRadius = 8.0f;
    locateBtn.layer.masksToBounds = NO;
    locateBtn.layer.shadowRadius = 1;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.locationManager startUpdatingLocation];
    
    mapView.delegate = self;
    mapView.showsUserLocation = NO;
    
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapView addGestureRecognizer:panRec];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(locationDone:)];
    doneButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)locatePress:(id)sender {
    if (self.followUser) {
        [self stopFollowing];
    } else {
        [self startFollowing];
    }
}

- (void)startFollowing {
    self.followUser = YES;
    [self.locationManager startUpdatingLocation]; // If not already following
    UIImage *buttonArrow = [UIImage imageNamed:@"LocationBlue.png"];
    [locateBtn setImage:buttonArrow forState:UIControlStateNormal];
}

- (void)stopFollowing {
    self.followUser = NO;
    UIImage *buttonArrow = [UIImage imageNamed:@"LocationGrey.png"];
    [locateBtn setImage:buttonArrow forState:UIControlStateNormal];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    
    if (self.overlayDot){
        [mapView removeOverlay:self.overlayDot];
        self.overlayDot = nil;
    }
    self.overlayDot = [MKCircle circleWithCenterCoordinate:location.coordinate
                                                    radius:4];
    [mapView addOverlay:self.overlayDot];
    
    if (self.followUser){
        double spanMeters = MAX(4*location.horizontalAccuracy, MIN_MAP_SPAN_METERS);
        mapView.region = MKCoordinateRegionMakeWithDistance(location.coordinate, spanMeters, spanMeters);
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if ([error domain] == kCLErrorDomain) {
        switch ([error code]) {
            case kCLErrorDenied:
                [self stopFollowing];
                [self.locationManager stopUpdatingLocation];
                if (self.overlayDot){
                    [mapView removeOverlay:self.overlayDot];
                    self.overlayDot = nil;
                }
                break;
            case kCLErrorNetwork: // general, network-related error
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:@"please check your network connection or that you are not in airplane mode"
                                           delegate:self
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil, nil] show];
                break;
            default:
                break;
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:error.localizedDescription
                                   delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil, nil] show];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    double radius;
    if (self.overlayCircle){
        [mapView removeOverlay:self.overlayCircle];
        self.overlayCircle = nil;
    }
    
    if (mapView.region.span.latitudeDelta < MAX_OVERLAY_LATITUDE_SPAN){
        if (self.followUser){
            radius = MIN(MAX(self.locationManager.location.horizontalAccuracy,
                             MIN_CIRCLE_RADIUS_METERS),
                         MAX_CIRCLE_RADIUS_METERS);
        } else {
            radius = DEFAULT_CIRCLE_RADIUS_METERS;
        }
        self.overlayCircle = [MKCircle circleWithCenterCoordinate:mapView.centerCoordinate
                                                           radius:radius];
        [mapView addOverlay:self.overlayCircle];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (MKOverlayView *)mapView:(MKMapView *)map viewForOverlay:(id <MKOverlay>)overlay
{
    if (overlay == self.overlayCircle){
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.8];
        circleView.lineWidth = 1;
        circleView.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
        return circleView;
    } else if(overlay == self.overlayDot){
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:1];
        circleView.lineWidth = 1;
        circleView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        return circleView;
    } else {
        return nil;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    if (self.followUser){
        [self stopFollowing];
    }
}

- (void)locationDone:(id)sender {
    if (!self.overlayCircle){
        return;
    }
    DBDoorphoneSetupViewController *numberController = [[DBDoorphoneSetupViewController alloc] initWithStyle:nil
                                                                                                location:mapView.centerCoordinate
                                                                                                   radius:self.overlayCircle.radius];
    [self.navigationController pushViewController:numberController
                                         animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
