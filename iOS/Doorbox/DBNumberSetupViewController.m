//
//  DBNumberSetupViewController.m
//  Doorbox
//
//  Created by Andrew Metcalf on 3/28/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import "DBNumberSetupViewController.h"
#import "DBRequest.h"
#import "DBResult.h"

@interface DBNumberSetupViewController ()

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loader;
@property (weak, nonatomic) IBOutlet UILabel *instructLandlordLabel;
@property (weak, nonatomic) IBOutlet UIView *hrView;
@property (weak, nonatomic) IBOutlet UILabel *callLabel;
@property (weak, nonatomic) IBOutlet UIButton *startCallBtn;

@property CLLocationCoordinate2D initLoc;
@property CLLocationDistance initRad;

@end

@implementation DBNumberSetupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameorNil
               bundle:(NSBundle *)nibBundleOrNil
             location:(CLLocationCoordinate2D)location
                radius:(CLLocationDistance)radius {
    if(self = [super initWithNibName:nil bundle:nil]){
        self.initLoc = location;
        self.initRad = radius;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.startCallBtn addTarget:self
                          action:@selector(startCall:)
                forControlEvents:UIControlEventTouchUpInside];
    
    DBRequest *request = [DBRequest createDoorphoneWithLocation:self.initLoc
                                                         radius:self.initRad];
    NSDictionary *responseDict = @{
                                   @"state": [NSNumber numberWithInt:DBDoorUnconfigured],
                                   @"latitude": [NSNumber numberWithDouble:self.initLoc.latitude],
                                   @"longitude": [NSNumber numberWithDouble:self.initLoc.longitude],
                                   @"radius": [NSNumber numberWithDouble:self.initRad],
                                   @"twilioNumber": @"(415)867-5309"
                                  };
    
    request.mockResponseResult = [[DBDoorphone alloc] initWithResponseDictionary:responseDict];
    [request startWithCompletionHandler:^(DBRequest *request, DBDoorphone *doorphone, NSError *error) {
        if(doorphone && doorphone.twilioNumber){
            [self.loader stopAnimating];
            self.numberLabel.text = doorphone.twilioNumber;
            self.startCallBtn.enabled = YES;
            [UIView animateWithDuration:0.3 animations:^(void) {
                self.numberLabel.hidden = NO;
                self.instructLandlordLabel.alpha = 1;
                self.hrView.alpha = 1;
                self.callLabel.alpha = 1;
                self.startCallBtn.alpha = 1;
            }];
        }
        
        if(error){
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:error.localizedDescription
                                       delegate:self
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil, nil] show];
            // TODO: Can we help provide a retry or something?
        }
    }];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)startCall:(id)sender{
    NSString *cleanPhoneNumber = [@"telprompt://" stringByAppendingString:self.numberLabel.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cleanPhoneNumber]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
