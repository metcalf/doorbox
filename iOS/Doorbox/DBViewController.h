//
//  DBViewController.h
//  Doorbox
//
//  Created by Andrew Metcalf on 2/6/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

uint8_t const DB_DEFAULT_LOG_LIMIT;

@interface DBViewController  : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSObject <UITableViewDataSource, UITableViewDelegate> *logTableSource;
    
    UILabel *titleLabel;
}

@property (weak, nonatomic) IBOutlet UITableView *logTable;
@property (weak, nonatomic) IBOutlet UITableView *buttonTable;

- (void) postLoginFunction;
- (void) refreshDoorphone;

@end
