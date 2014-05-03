//
//  detailViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 4/29/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "detailViewController.h"
#import "personEditViewController.h"
#import "addressEditViewController.h"
#import "addressDetailViewController.h"
#import "houndAppDelegate.h"

@interface detailViewController ()
@end

@implementation detailViewController

@synthesize person, notes, addresses, tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    notes.layer.cornerRadius = 8.0f;
    notes.layer.masksToBounds = NO;
    notes.layer.borderWidth = .5f;
    notes.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.automaticallyAdjustsScrollViewInsets=NO;
    [self refreshView];
}

- (void) refreshView
{
    NSString *fullName=[NSString stringWithFormat:@"%@ %@",[person valueForKey:@"fname"],[person valueForKey:@"lname"]];
    self.navigationItem.title=fullName;
    notes.text=person.notes;
    addresses=[NSMutableArray arrayWithObjects:nil];
    for( id item in person.addresses )
    {
        [addresses addObject:item];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)unwindToTableViewController:(UIStoryboardSegue *)sender
{
    personEditViewController *editVC = (personEditViewController *)sender.sourceViewController;
    NSString *newname = [NSString stringWithFormat:@"%@ %@",editVC.fname.text,editVC.lname.text] ;
    if( ![newname length]==0 && ![[newname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 )
    {
        houndAppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        [person setValue:editVC.fname.text forKey:@"fname"];
        [person setValue:editVC.lname.text forKey:@"lname"];
        [person setValue:editVC.notes.text forKey:@"notes"];
        NSError *error=nil;
        if( ![context save:&error] ) NSLog(@"Save failed! %@ %@",error, [error localizedDescription]);
    }
    [self refreshView];
    [editVC dismissViewControllerAnimated:YES completion:nil];
    /*
    NSLog(@"Unwinding to table detail view controller.");
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
             NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
             int row=[myIndexPath row];
             Address *address=[addresses objectAtIndex:row];
             [address setValue:editVC.addr1.text forKey:@"addr1"];
             [address setValue:editVC.addr2.text forKey:@"addr2"];
             [address setValue:editVC.city.text forKey:@"city"];
             [address setValue:editVC.state.text forKey:@"state"];
             [address setValue:editVC.zip.text forKey:@"zip"];
             [address setValue:editVC.phone.text forKey:@"phone"];
             [address setValue:editVC.notes.text forKey:@"notes"];
             [address setValue:[NSNumber numberWithDouble:placemark.coordinate.longitude] forKey:@"longitude"];
             [address setValue:[NSNumber numberWithDouble:placemark.coordinate.latitude] forKey:@"latitude"];
             address.person=editVC.person;
             NSError *error=nil;
             if( ![context save:&error] ) NSLog(@"Save failed! %@ %@",error, [error localizedDescription]);
             [self refreshView];
             [editVC dismissViewControllerAnimated:YES completion:nil];
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Address not found" message: @"That address could not be found on the map!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
         }
     }
     ];
     */
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Prepare for segue: %@", [segue identifier]);
    if( [[segue identifier] isEqualToString:@"Update"] )
    {
        personEditViewController *vc = [segue destinationViewController];
        vc.person = person;
    }
    else if( [[segue identifier] isEqualToString:@"New"] )
    {
        addressEditViewController *addrVC = [segue destinationViewController];
        addrVC.person=person;
    }
    else if( [[segue identifier] isEqualToString:@"ViewAddress"] )
    {
        addressDetailViewController *vc = [segue destinationViewController];
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        int row=[myIndexPath row];
        vc.address=[addresses objectAtIndex:row];
    }
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
    return [addresses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if( cell==nil )
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    Address *obj=[addresses objectAtIndex:indexPath.row];
    cell.textLabel.text=[self formatAddress:obj];
    return cell;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    houndAppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    if( editingStyle==UITableViewCellEditingStyleDelete )
    {
        [context deleteObject:[addresses objectAtIndex:indexPath.row]];
        NSError *error=nil;
        if(![context save:&error] )
        {
            NSLog(@"Can't delete! %@ %@",error, [error localizedDescription]);
            return;
        }
        [addresses removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

@end
