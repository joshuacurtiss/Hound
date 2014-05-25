//
//  addressesTableViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 4/29/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "addressesTableViewController.h"
#import "addressEditViewController.h"
#import "addressDetailViewController.h"
#import "addressService.h"
#import "Address+Setters.h"
#import "Util.h"

@interface addressesTableViewController ()
{
    NSString *sortField;
    NSMutableDictionary *dataDict;
    NSArray *sectionTitles;
    addressService *addrsvc;
    Util *util;
}
@end

@implementation addressesTableViewController
@synthesize data;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        NSLog(@"Init %@.",self.class);
        addrsvc=[[addressService alloc] init];
        util=[[Util alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    sortField=@"city";
}

- (void) viewWillAppear:(BOOL)animated
{
    [self refreshTable];
}

- (void) refreshTable
{
    NSLog(@"Reloading data and refreshing the table.");
    data=[[addrsvc fetchWithSort:[NSArray arrayWithObjects:sortField, @"addr1", @"addr2", nil]] mutableCopy];
    dataDict=[[NSMutableDictionary alloc] init];
    for( int i=0 ; i<data.count ; i++ )
    {
        Address *addr=data[i];
        NSString *sec = [addr valueForKeyPath:sortField];
        if( !dataDict[sec] ) dataDict[sec]=[NSMutableArray arrayWithObjects:nil];
        [dataDict[sec] addObject:addr];
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
    return [sectionTitles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *secTitle=sectionTitles[section];
    NSArray *sec=dataDict[secTitle];
    return sec.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if( cell==nil )
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    NSString *secTitle=sectionTitles[indexPath.section];
    NSArray *sec=dataDict[secTitle];
    Address *addr=sec[indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"%@", [addr formatSingleline]];
    return cell;
}

- (IBAction)unwindToTableViewController:(UIStoryboardSegue *)sender
{
    NSLog(@"Unwinding to the table view controller.");
    addressEditViewController *editVC = (addressEditViewController *)sender.sourceViewController;
    Address *newObj=[addrsvc edit:nil addr1:editVC.addr1.text addr2:editVC.addr2.text city:editVC.city.text state:editVC.state.text zip:editVC.zip.text phone:editVC.phone.text notes:editVC.notes.text person:editVC.person];
    BOOL hasInternet=[util checkInternet];
    if( hasInternet )
    {
        [addrsvc findCoordsForAddress:newObj completion:^(BOOL success) {
            if(!success)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Address not found" message: @"That address could not be found on the map!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    [self refreshTable];
    [editVC dismissViewControllerAnimated:YES completion:nil];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( editingStyle==UITableViewCellEditingStyleDelete )
    {
        NSString *secTitle=sectionTitles[indexPath.section];
        NSArray *sec=dataDict[secTitle];
        Address *addr=sec[indexPath.row];
        [addrsvc del:addr];
        [dataDict[secTitle] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [[segue identifier] isEqualToString:@"Show"] )
    {
        addressDetailViewController *detailVC = [segue destinationViewController];
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        NSString *secTitle=sectionTitles[myIndexPath.section];
        NSArray *sec=dataDict[secTitle];
        Address *addr=sec[myIndexPath.row];
        detailVC.address = addr;
    }
}

- (IBAction)sortFieldChanged:(id)sender
{
    sortField=(((UISegmentedControl *) sender).selectedSegmentIndex==0)?@"city":@"zip";
    NSLog(@"Changed sort to %@.",sortField);
    [self refreshTable];
}

@end
