//
//  DBLoginViewController.m
//  Doorbox
//
//  Created by Andrew Metcalf on 2/6/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import "DBLoginViewController.h"
#import "DBAppDelegate.h"

@interface DBLoginViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loader;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;

@end

@implementation DBLoginViewController

- (IBAction)performLogin:(id)sender {
    [self.instructionLabel setHidden:YES];
    [self.loader startAnimating];
    
    DBAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openSessionWithAllowLoginUI:YES];
}

- (void)loginFailed {
    [self.loader stopAnimating];
    [self.instructionLabel setHidden:NO];
}

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
