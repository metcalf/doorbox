//
//  DBDoorphoneSetupViewController.m
//  Doorbox
//
//  Created by Andrew Metcalf on 3/29/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import "DBDoorphoneSetupViewController.h"

#import "DBRequest.h"
#import "DBResult.h"

typedef enum {
    DBSetupNumber = 0,
    DBSetupCode = 1,
    DBSetupReady = 2,
    DBSetupCall = 3,
    DBSetupDone = 4
} DBSetupStep;

@interface DBDoorphoneSetupViewController ()

@property DBSetupStep step;

@property (strong, nonatomic) IBOutlet UITableViewCell *numberSetupCell;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *numberLoader;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIButton *numberDoneBtn;

@property (strong, nonatomic) IBOutlet UITableViewCell *codeSetupCell;
@property (weak, nonatomic) IBOutlet UITextField *codeField;

@property (strong, nonatomic) IBOutlet UITableViewCell *readySetupCell;
@property (weak, nonatomic) IBOutlet UIButton *readyBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *readyLoader;

@property (strong, nonatomic) IBOutlet UITableViewCell *callSetupCell;
@property (weak, nonatomic) IBOutlet UIButton *callSuccessBtn;
@property (weak, nonatomic) IBOutlet UIButton *callFailBtn;

- (IBAction)numberSetupDone:(id)sender;
- (IBAction)codeChanged:(id)sender;
- (IBAction)readyDone:(id)sender;
- (IBAction)callSuccess:(id)sender;
- (IBAction)callFail:(id)sender;

@property CLLocationCoordinate2D initLoc;
@property CLLocationDistance initRad;
@property NSString *doorphoneId;

@end

@implementation DBDoorphoneSetupViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
           location:(CLLocationCoordinate2D)location
             radius:(CLLocationDistance)radius {
    if (self = [super initWithStyle:style]) {
        self.initLoc = location;
        self.initRad = radius;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
            [self.numberLoader stopAnimating];
            self.numberLabel.text = doorphone.twilioNumber;
            self.numberLabel.hidden = NO;
            self.numberDoneBtn.enabled = YES;
            self.doorphoneId = doorphone.id;
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

- (void)transitionToState:(DBSetupStep)newStep {
    if (newStep <= DBSetupCode) {
        self.codeField.text = @"";
    }
    switch (newStep) {
        case DBSetupCode:
            [self.codeField becomeFirstResponder];
            break;
            
        default:
            break;
    }
    self.step = newStep;
    [self.tableView reloadData];
}

- (IBAction)numberSetupDone:(id)sender {
    [self transitionToState:DBSetupCode];
}
- (IBAction)codeChanged:(id)sender {
    NSString *value = self.codeField.text;
    
    if (value.length < 1 || value.length > 6){
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Invalid code, please enter again"
                                   delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil, nil] show];
        self.codeField.text = @"";
        [self.codeField becomeFirstResponder];
        return;
    }
    
    self.readyBtn.enabled = NO;
    [self.readyLoader startAnimating];
    
    DBRequest *request = [DBRequest updateDoorphone:self.doorphoneId
                                         accessCode:value];
    NSDictionary *responseDict = @{
                                   @"accessCode": value
                                   };
    request.mockResponseResult = [[DBDoorphone alloc] initWithResponseDictionary:responseDict];

    
    [request startWithCompletionHandler:^(DBRequest *request, DBDoorphone *doorphone, NSError *error) {
        // TODO: Need some type of response code handling here?
        if(error){
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:error.localizedDescription
                                       delegate:self
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil, nil] show];
        }
        
        if (doorphone.accessCode){
            self.readyBtn.enabled = YES;
            [self.readyLoader stopAnimating];
        }
    }];
    
    [self.codeField resignFirstResponder];
    [self transitionToState:DBSetupReady];
}
- (IBAction)readyDone:(id)sender {
    [self transitionToState:DBSetupCall];
}
- (IBAction)callSuccess:(id)sender {
    DBRequest *request = [DBRequest updateDoorphone:self.doorphoneId
                                             active:YES];
    NSDictionary *responseDict = @{
                                   @"active": YES
                                   };
    request.mockResponseResult = [[DBDoorphone alloc] initWithResponseDictionary:responseDict];

    
    [request startWithCompletionHandler:^(DBRequest *request, DBDoorphone *doorphone, NSError *error) {
        if(error){
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:error.localizedDescription
                                       delegate:self
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil, nil] show];
        }
        
        if (doorphone.accessCode){
            // Push, pop, do your navigation thing!
        }
    }];
    
    [self transitionToState:DBSetupDone];
}
- (IBAction)callFail:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Setup failed"
                                message:@"Check that you configured things correctly and try again"
                               delegate:self
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil, nil] show];
    
    [self transitionToState:DBSetupNumber];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.step){
        switch (indexPath.item){
            case DBSetupNumber:
                return self.numberSetupCell;
            case DBSetupCode:
                return self.codeSetupCell;
            case DBSetupReady:
                return self.readySetupCell;
            case DBSetupCall:
                return self.callSetupCell;
            default:
                return nil;
        }
    } else {
        static NSString *CellIdentifier = @"SetupCell";
        NSString *cellText;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if(indexPath.item > self.step){
            cell.textLabel.alpha = 0.5;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            switch (indexPath.item){
                case DBSetupNumber:
                    cellText = @"Configure doorphone number";
                    break;
                case DBSetupCode:
                    cellText = @"Set doorphone code";
                    break;
                case DBSetupReady:
                    cellText = @"Prepare for test call";
                    break;
                case DBSetupCall:
                    cellText = @"Test your doorphone";
                    break;
                default:
                    cellText = @"";
            }
            
        } else { // < current step
            cell.textLabel.alpha = 1;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            switch (indexPath.item){
                case DBSetupNumber:
                    cellText = [@"Doorbox number: " stringByAppendingString:self.numberLabel.text];
                    break;
                case DBSetupCode:
                    cellText = [@"Access Code: " stringByAppendingString:self.codeField.text];
                    break;
                case DBSetupReady:
                    cellText = @"Ready to test";
                    break;
                case DBSetupCall:
                    cellText = @"Setup complete";
                    break;
                default:
                    cellText = @"";
            }
        }
        
        cell.textLabel.text = cellText;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.step){
        switch (indexPath.item){
            case 0:
                return self.numberSetupCell.frame.size.height;
            case 1:
                return self.codeSetupCell.frame.size.height;
            case 2:
                return self.readySetupCell.frame.size.height;
            case 3:
                return self.callSetupCell.frame.size.height;
            default:
                return 0;
        }
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.item < self.step){
        [self transitionToState:indexPath.item];
    }
}
@end
