//
//  DBViewController.m
//  Doorbox
//
//  Created by Andrew Metcalf on 2/6/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import "DBViewController.h"
#import "DBResult.h"
#import "DBRequest.h"
#import "DBAppDelegate.h"
#import "DBLocationSetupViewController.h"
#import "DBUnlockSharedViewController.h"

NSString *const LOADING_HEADER = @"Loading...";
NSString *const LOCKED_HEADER = @"Locked";
NSString *const UNLOCKED_HEADER = @"Unlocked";
NSString *const UNCONFIGURED_HEADER = @"Doorbox";

uint8_t const DB_DEFAULT_LOG_LIMIT = 10;

@interface LogTableSource : NSObject  {
    NSArray *logData;
    UITableView *tableView;
}

- (id)initWithTableView:(UITableView*)tableView;


- (void)refreshData;
- (void)clearData;

@end

@interface DBViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logHeightConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loader;

@property DBDoorphone *doorphone;

@property (strong, nonatomic) DBLocationSetupViewController *locationSetupViewController;
@property (strong, nonatomic) DBUnlockSharedViewController *unlockSharedViewController;

@end

@implementation DBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    logTableSource = [[LogTableSource alloc] initWithTableView:self.logTable];
    [self.logTable setDataSource:logTableSource];
    [self.logTable setDelegate:logTableSource];
    
    //buttonTableSource = [[ButtonTableSource alloc] initWithTableView:self.buttonTable];
    //[self.buttonTable setDataSource:buttonTableSource];
    //[self.buttonTable setDelegate:buttonTableSource];
    
    [self updateLoadingState:YES];
    if([DBSession activeSession].state == DBSessionStateOpen){
        [self refreshDoorphone];
    }
    
    [self setTitle:@"Home"];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)postLoginFunction {
    [self updateLoadingState:YES];
    [self refreshDoorphone];
}

- (void)refreshDoorphone {
    DBRequest *request = [DBRequest getDoorphone];
    [request startWithCompletionHandler:^(DBRequest *request, DBDoorphone *doorphone, NSError *error) {
        [self updateLoadingState:NO];
        if (doorphone) {
            self.doorphone = doorphone;
        } else if(!error){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Invalid response: missing doorphone"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        if(error){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error: %d", error.code]
                                                                 message:error.localizedDescription
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
            [alertView show];
        }
    }];
    // TODO: Ensure only one refresh occurs at a time
}

- (void)updateLoadingState:(BOOL)state {
    if(state){
        titleLabel.text = LOADING_HEADER;
        [titleLabel sizeToFit];
        [self hideLogTable];
        [self.buttonTable setHidden:YES];
        [self.loader startAnimating];
    } else {
        [self.loader stopAnimating];
    }
}

- (void)setDoorphone:(DBDoorphone*)newDoorphone {
    _doorphone = newDoorphone;
    switch (self.doorphone.state) {
        case DBDoorLocked:
            titleLabel.text = LOCKED_HEADER;
            [self showLogTable];
            break;
        case DBDoorUnlocked:
            titleLabel.text = UNLOCKED_HEADER;
            [self showLogTable];
            break;
        /*case DBDoorSetup:
            if(!self.locationSetupController){
                self.locationSetupController = [[DBLocationSetupViewController alloc]
                                                initWithNibName:nil bundle:nil];
            }
            [self.navigationController pushViewController:self.locationSetupController
                                                 animated:YES];
            break;*/
        case DBDoorUnconfigured:
            titleLabel.text = UNCONFIGURED_HEADER;
            [self hideLogTable];
            break;
        default:
            break;
    }
    [titleLabel sizeToFit];
    [self.buttonTable reloadData];
    [self.buttonTable setHidden:NO];
}

- (void)hideLogTable {
    [self.logTable setHidden:YES];
    self.logHeightConstraint.priority = 700;
    [(LogTableSource*)logTableSource clearData];
}

- (void)showLogTable {
    [(LogTableSource*)logTableSource refreshData];
    self.logHeightConstraint.priority = 900;
    [self.logTable setHidden:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.doorphone == nil){
        return; // TODO: Raise an error... shouldn't be able to do this
    }
    
    UIViewController *target;
    
    if (self.doorphone.state == DBDoorUnconfigured) {
        switch (indexPath.item) {
            case 0: // Unlock shared
                target = [[DBUnlockSharedViewController alloc] init];
                break;
            case 1: // Setup
                target = [[DBLocationSetupViewController alloc] init];
                break;
        }
    } else {
        switch (indexPath.item) {
            case 0:  // Lock/unlock
                break;
            case 1: // Share keys
                break;
            case 2: // Unlock shared
                target = [[DBUnlockSharedViewController alloc] init];
                break;
            case 3: // Settings
                break;
        }
    }
    
    [self.navigationController pushViewController:target animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (self.doorphone == nil){
        return 0;
    }
    switch (self.doorphone.state) {
        case DBDoorLocked:
        case DBDoorUnlocked:
            return 4;
        case DBDoorUnconfigured:
            return 2;
        default: // nil
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text;
    NSString *imageName;
    
    if(self.doorphone == nil){
        return nil; // TODO: Raise an error, shouldn't be able to do this
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (self.doorphone.state == DBDoorUnconfigured) {
        switch (indexPath.item) {
            case 0: // Unlock shared
                text = @"Open a friend's Doorbox";
                imageName = @"";
                break;
            case 1: // Setup
                text = @"Setup my Doorbox";
                imageName = @"";
                break;
        }
    } else {
        switch (indexPath.item) {
            case 0:  // Lock/unlock
                if(self.doorphone.state == DBDoorLocked){
                    text = @"Unlock my Doorbox";
                    imageName = @"";
                } else {
                    text = @"Lock my Doorbox";
                    imageName = @"";
                }
                break;
            case 1: // Share keys
                text = @"Share my keys";
                imageName = @"";
                break;
            case 2: // Unlock shared
                text = @"Open a friend's Doorbox";
                imageName = @"";
                break;
            case 3: // Settings
                text = @"My Doorbox settings";
                imageName = @"";
                break;
        }
    }
    
    cell.textLabel.text = text;
    //cell.imageView.image = [UIImage imageNamed:imageName];

    return cell;
}

@end

@implementation LogTableSource

- (id)initWithTableView:(UITableView *)l_tableView {
    if(self = [super init]){
        tableView = l_tableView;
    }
    return self;
}

- (void)refreshData {
    DBRequest *request = [DBRequest getLogEventsWithLimit:DB_DEFAULT_LOG_LIMIT];
    request.mockResponseResult = @[];

    [request startWithCompletionHandler:^(DBRequest *request, NSArray *logEvents, NSError *error) {
        if(error){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error: %d", error.code]
                                                                message:error.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            [self setData:logEvents];
        }
    }];
    // TODO: Ensure only one refresh occurs at a time
}

- (void)setData:(NSArray*)data {
    logData = data;
    [tableView reloadData];
}

- (void)clearData {
    logData = nil;
    [tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if(!logData){
        return 1;
    } else {
        return logData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(!logData){
        cell.textLabel.text = @"No recent activity!";
        return cell;
    }
    
    DBLogEntry *entry = (DBLogEntry*)logData[indexPath.item];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", entry.text, [self formatLogDate:entry.time]];
    //cell.imageView.image = [UIImage imageNamed:imageName];
    
    return cell;
}

-(NSString *)formatLogDate:(NSDate *)then {
    NSString *dayName;
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *now = [NSDate date];
    unsigned int unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *diffComps = [gregorian components:unitFlags fromDate:then toDate:now options:0];
    
    if([diffComps day] == 0){
        if ([diffComps minute] < 1) {
            return @"less than a minute ago";
        } else if ([diffComps minute] < 60) {
            return [NSString stringWithFormat:@"%d minutes ago", [diffComps minute]];
        } else {
            dayName = @"";
        }
    } else if ([diffComps day] == 1) {
        dayName = @"yesterday";
    } else {
        dayName = [NSString stringWithFormat:@"%d days ago", [diffComps day]];
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"HH:mm a"];
    
    return [NSString stringWithFormat:@"%@ at %@", dayName, [df stringFromDate:then]];
}

@end