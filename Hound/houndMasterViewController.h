//
//  houndMasterViewController.h
//  Hound
//
//  Created by Joshua Curtiss on 4/7/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import <UIKit/UIKit.h>

@class houndDetailViewController;

#import <CoreData/CoreData.h>

@interface houndMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) houndDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
