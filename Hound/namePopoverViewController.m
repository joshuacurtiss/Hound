//
//  namePopoverViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 5/3/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "namePopoverViewController.h"
#import "personService.h"
#import "addressEditViewController.h"

@interface namePopoverViewController ()
{
    personService *personsvc;
}
@end

@implementation namePopoverViewController
@synthesize data;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        personsvc=[[personService alloc] init];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        personsvc=[[personService alloc] init];
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
    data=[[personsvc fetchWithSort:[NSArray arrayWithObjects:@"lname",@"fname",nil]] mutableCopy];
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
    Person *person=[data objectAtIndex:indexPath.row];
    cell.textLabel.text=[person fullNameLastFirst];
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
