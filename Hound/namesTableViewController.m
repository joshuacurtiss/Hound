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
{
    NSMutableDictionary *dataDict;
    NSArray *sectionTitles;
}
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
    //[self.tabBarController setSelectedIndex:3]; // Debugging line to go straight to a particular view. Left for reference.
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
    dataDict=[[NSMutableDictionary alloc] init];
    for( int i=0 ; i<data.count ; i++ )
    {
        Person *p=data[i];
        NSString *letter = [p.lname substringToIndex:1];
        if( !dataDict[letter] ) dataDict[letter]=[NSMutableArray arrayWithObjects:nil];
        [dataDict[letter] addObject:p];
    }
    sectionTitles=[[dataDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *secTitle=sectionTitles[section];
    NSArray *sec=dataDict[secTitle];
    return sec.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sectionTitles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *secTitle=sectionTitles[indexPath.section];
    NSArray *sec=dataDict[secTitle];
    if( cell==nil )
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    Person *person=sec[indexPath.row];
    NSLog(@"Section %d Row %d = %@", indexPath.section, indexPath.row, person);
    cell.textLabel.text=[NSString stringWithFormat:@"%@, %@", person.lname, person.fname];
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
        NSString *secTitle=sectionTitles[indexPath.section];
        NSArray *sec=dataDict[secTitle];
        Person *p=sec[indexPath.row];
        [context deleteObject:p];
        NSError *error=nil;
        if(![context save:&error] )
        {
            NSLog(@"Can't delete! %@ %@",error, [error localizedDescription]);
            return;
        }
        [dataDict[secTitle] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [[segue identifier] isEqualToString:@"Show"] )
    {
        detailViewController *detailVC = [segue destinationViewController];
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        NSString *secTitle=sectionTitles[myIndexPath.section];
        NSArray *sec=dataDict[secTitle];
        detailVC.person = sec[myIndexPath.row];
    }
}

@end
