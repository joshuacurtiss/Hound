//
//  addressesTableViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 4/29/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "addressesTableViewController.h"
#import "addressEditViewController.h"

@interface addressesTableViewController ()

@end

@implementation addressesTableViewController
@synthesize data;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    data=[[NSMutableArray alloc] initWithObjects:@"123",@"456",@"789", nil];
    self.navigationItem.leftBarButtonItem=self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if( cell==nil )
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.textLabel.text=[data objectAtIndex:indexPath.row];
    return cell;
}

- (IBAction)unwindToTableViewController:(UIStoryboardSegue *)sender
{
    addressEditViewController *editVC = (addressEditViewController *)sender.sourceViewController;
    NSString *addr = [NSString stringWithFormat:@"%@",editVC.addr1.text] ;
    if( ![addr length]==0 && ![[addr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 )
    {
        [data insertObject:addr atIndex:0];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( editingStyle==UITableViewCellEditingStyleDelete )
    {
        // Remove item from array
        [data removeObjectAtIndex:indexPath.row];
        // Remove from table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
    if( [[segue identifier] isEqualToString:@"ShowDetails"] )
    {
        detailViewController *detailVC = [segue destinationViewController];
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        int row=[myIndexPath row];
        detailVC.detail = @[[data objectAtIndex:row]];
    }
    */
}

@end
