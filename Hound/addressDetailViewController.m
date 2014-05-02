//
//  addressDetailViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 5/1/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "addressDetailViewController.h"
#import "addressEditViewController.h"
#import "houndAppDelegate.h"

@interface addressDetailViewController ()
@end

@implementation addressDetailViewController

@synthesize address;

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
    [self refreshView];
}

- (void) refreshView
{
    NSString *fullAddr=[NSString stringWithFormat:@"%@ %@ %@ %@ %@",[address valueForKey:@"addr1"],[address valueForKey:@"addr2"],[address valueForKey:@"city"],[address valueForKey:@"state"],[address valueForKey:@"zip"]];
    self.navigationItem.title=fullAddr;
    self.addr1.text=fullAddr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwindToTableViewController:(UIStoryboardSegue *)sender
{
    NSLog(@"Unwinding to detail view controller.");
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
             [address setValue:editVC.addr1.text forKey:@"addr1"];
             [address setValue:editVC.addr2.text forKey:@"addr2"];
             [address setValue:editVC.city.text forKey:@"city"];
             [address setValue:editVC.state.text forKey:@"state"];
             [address setValue:editVC.zip.text forKey:@"zip"];
             [address setValue:editVC.phone.text forKey:@"phone"];
             [address setValue:editVC.notes.text forKey:@"notes"];
             [address setValue:[NSNumber numberWithDouble:placemark.coordinate.longitude] forKey:@"longitude"];
             [address setValue:[NSNumber numberWithDouble:placemark.coordinate.latitude] forKey:@"latitude"];
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
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Prepare for segue: %@", [segue identifier]);
    if( [[segue identifier] isEqualToString:@"Update"] )
    {
        addressEditViewController *vc = [segue destinationViewController];
        vc.address = address;
    }
}

@end
