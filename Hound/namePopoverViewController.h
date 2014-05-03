//
//  namePopoverViewController.h
//  Hound
//
//  Created by Joshua Curtiss on 5/3/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface namePopoverViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *data;
@property (nonatomic, copy) void (^personSelected)(Person *newperson);
@end
