//
//  namesTableViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 4/29/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "namesTableViewController.h"
#import "personEditViewController.h"
#import "detailViewController.h"

@interface namesTableViewController ()

@end

@implementation namesTableViewController
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
    data=[[NSMutableArray alloc] initWithObjects:@"Dog",@"Cat",@"Mouse", nil];
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
    personEditViewController *editVC = (personEditViewController *)sender.sourceViewController;
    NSString *name = [NSString stringWithFormat:@"%@, %@",editVC.lname.text,editVC.fname.text] ;
    if( ![name length]==0 && ![[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 )
    {
        [data insertObject:name atIndex:0];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
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
    if( [[segue identifier] isEqualToString:@"ShowDetails"] )
    {
        detailViewController *detailVC = [segue destinationViewController];
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        int row=[myIndexPath row];
        detailVC.detail = @[[data objectAtIndex:row]];
    }
}

@end
