//
//  namePopoverViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 5/3/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "namePopoverViewController.h"
#import "houndAppDelegate.h"
#import "addressEditViewController.h"

@interface namePopoverViewController ()
@end

@implementation namePopoverViewController
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
    [self refreshTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if( cell==nil )
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    NSManagedObject *person=[data objectAtIndex:indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"%@, %@", [person valueForKey:@"lname"], [person valueForKey:@"fname"]];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Segue is happening!");
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Person *person=[data objectAtIndex:indexPath.row];
    NSLog(@"You choose %@", [person valueForKey:@"fname"]);
    self.personSelected(person);
}

@end
