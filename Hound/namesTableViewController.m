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
#import "houndAppDelegate.h"

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
    self.navigationItem.leftBarButtonItem=self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self refreshTable];
}

- (void) refreshTable
{
    NSLog(@"Reloading data and refreshing the table.");
    houndAppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    [request setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"lname" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
                                 [NSSortDescriptor sortDescriptorWithKey:@"fname" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]];
    NSError *error;
    data=[[context executeFetchRequest:request error:&error] mutableCopy];
    [self.tableView reloadData];
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
    NSManagedObject *person=[data objectAtIndex:indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"%@, %@", [person valueForKey:@"lname"], [person valueForKey:@"fname"]];
    return cell;
}

- (IBAction)unwindToTableViewController:(UIStoryboardSegue *)sender
{
    NSLog(@"Unwinding to table view controller.");
    personEditViewController *editVC = (personEditViewController *)sender.sourceViewController;
    NSString *newname = [NSString stringWithFormat:@"%@ %@",editVC.fname.text,editVC.lname.text] ;
    if( ![newname length]==0 && ![[newname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 )
    {
        houndAppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSManagedObjectContext *newPerson;
        newPerson=[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
        [newPerson setValue:editVC.fname.text forKey:@"fname"];
        [newPerson setValue:editVC.lname.text forKey:@"lname"];
        [newPerson setValue:editVC.notes.text forKey:@"notes"];
        NSError *error=nil;
        if( ![context save:&error] ) NSLog(@"Save failed! %@ %@",error, [error localizedDescription]);
    }
    [self refreshTable];
    [editVC dismissViewControllerAnimated:YES completion:nil];
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
    houndAppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    if( editingStyle==UITableViewCellEditingStyleDelete )
    {
        [context deleteObject:[data objectAtIndex:indexPath.row]];
        NSError *error=nil;
        if(![context save:&error] )
        {
            NSLog(@"Can't delete! %@ %@",error, [error localizedDescription]);
            return;
        }
        [data removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [[segue identifier] isEqualToString:@"Show"] )
    {
        detailViewController *detailVC = [segue destinationViewController];
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        int row=[myIndexPath row];
        detailVC.person = [data objectAtIndex:row];
    }
}

@end
