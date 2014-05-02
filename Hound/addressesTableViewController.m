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
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Address" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    [request setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"state" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
                                 [NSSortDescriptor sortDescriptorWithKey:@"city" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
                                 [NSSortDescriptor sortDescriptorWithKey:@"addr1" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
                                 [NSSortDescriptor sortDescriptorWithKey:@"addr2" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]];
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
    NSManagedObject *obj=[data objectAtIndex:indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"%@ %@", [obj valueForKey:@"addr1"], [obj valueForKey:@"addr2"]];
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
             NSManagedObjectContext *newObj;
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
        addressDetailViewController *detailVC = [segue destinationViewController];
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        int row=[myIndexPath row];
        detailVC.address = [data objectAtIndex:row];
    }
}

@end
