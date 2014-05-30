//
//  detailViewController.h
//  Hound
//
//  Created by Joshua Curtiss on 4/29/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "Address.h"

@interface detailViewController : UIViewController
@property (strong) Person *person;
@property (strong, nonatomic) IBOutlet UITextView *notes;
@property (strong, nonatomic) NSMutableArray *addresses;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
