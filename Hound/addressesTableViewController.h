//
//  addressesTableViewController.h
//  Hound
//
//  Created by Joshua Curtiss on 4/29/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface addressesTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *data;
@end
