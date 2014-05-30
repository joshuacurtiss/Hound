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
#import "houndAppDelegate.h"

@interface addressesTableViewController ()
{
    NSString *sortField;
    NSMutableDictionary *dataDict;
    NSArray *sectionTitles;
}
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
    sortField=@"city";
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
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Address" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    [request setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:sortField ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
                                                          [NSSortDescriptor sortDescriptorWithKey:@"addr1" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
                                                          [NSSortDescriptor sortDescriptorWithKey:@"addr2" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]];
    NSError *error;
    data=[[context executeFetchRequest:request error:&error] mutableCopy];
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
    cell.textLabel.text=[NSString stringWithFormat:@"%@", [self formatAddress:addr]];
    return cell;
}

- (IBAction)unwindToTableViewController:(UIStoryboardSegue *)sender
{
    NSLog(@"Unwinding to table view controller.");
    addressEditViewController *editVC = (addressEditViewController *)sender.sourceViewController;
    NSString *fullAddr=[NSString stringWithFormat:@"%@ %@ %@ %@ %@",editVC.addr1.text,editVC.addr2.text,editVC.city.text,editVC.state.text,editVC.zip.text];
    NSLog(@"Will be looking for: %@",fullAddr);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:fullAddr
                 completionHandler:^(NSArray* placemarks, NSError* error)
     {
         if (placemarks && placemarks.count > 0)
         {
             CLPlacemark *topResult = [placemarks objectAtIndex:0];
             MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
             NSLog(@"Coordinates are: %f, %f", placemark.coordinate.longitude, placemark.coordinate.latitude);
             houndAppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
             NSManagedObjectContext *context = [appDelegate managedObjectContext];
             Address *newObj;
             newObj=[NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:context];
             [newObj setValue:editVC.addr1.text forKey:@"addr1"];
             [newObj setValue:editVC.addr2.text forKey:@"addr2"];
             [newObj setValue:editVC.city.text forKey:@"city"];
             [newObj setValue:editVC.state.text forKey:@"state"];
             [newObj setValue:editVC.zip.text forKey:@"zip"];
             [newObj setValue:editVC.phone.text forKey:@"phone"];
             [newObj setValue:editVC.notes.text forKey:@"notes"];
             [newObj setValue:[NSNumber numberWithDouble:placemark.coordinate.longitude] forKey:@"longitude"];
             [newObj setValue:[NSNumber numberWithDouble:placemark.coordinate.latitude] forKey:@"latitude"];
             newObj.person=editVC.person;
             NSError *error=nil;
             if( ![context save:&error] ) NSLog(@"Save failed! %@ %@",error, [error localizedDescription]);
             [self refreshTable];
             [editVC dismissViewControllerAnimated:YES completion:nil];
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Address not found" message: @"That address could not be found on the map!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
         }
     }
     ];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    houndAppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    if( editingStyle==UITableViewCellEditingStyleDelete )
    {
        NSString *secTitle=sectionTitles[indexPath.section];
        NSArray *sec=dataDict[secTitle];
        Address *addr=sec[indexPath.row];
        [context deleteObject:addr];
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
        addressDetailViewController *detailVC = [segue destinationViewController];
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        NSString *secTitle=sectionTitles[myIndexPath.section];
        NSArray *sec=dataDict[secTitle];
        Address *addr=sec[myIndexPath.row];
        detailVC.address = addr;
    }
}

- (NSString *) formatAddress:(Address *)addr
{
    NSString *out=[self trimString:addr.addr1];
    if( [[self trimString:addr.addr2] length]>0 ) out=[NSString stringWithFormat:@"%@ %@",out,[self trimString:addr.addr2]];
    if( [[self trimString:addr.city] length]>0 ) out=[NSString stringWithFormat:@"%@, %@",out,[self trimString:addr.city]];
    if( [[self trimString:addr.state] length]>0 || [[self trimString:addr.zip] length]>0 ) out=[NSString stringWithFormat:@"%@, %@",out,[self trimString:[NSString stringWithFormat:@"%@ %@",addr.state,addr.zip]]];
    return out;
}

- (NSString *) trimString:(NSString *)str
{
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (IBAction)sortFieldChanged:(id)sender
{
    sortField=(((UISegmentedControl *) sender).selectedSegmentIndex==0)?@"city":@"zip";
    NSLog(@"Changed sort to %@.",sortField);
    [self refreshTable];
}
@end
