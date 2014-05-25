//
//  addressDetailViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 5/1/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "addressDetailViewController.h"
#import "addressEditViewController.h"
#import "Util.h"
#import "addressService.h"
#import "Person+Setters.h"

@interface addressDetailViewController ()
{
    addressService *addrsvc;
    Util *util;
}
@end

@implementation addressDetailViewController

@synthesize address, mapview, addrText, noteText;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if( self )
    {
        NSLog(@"Init %@.",self.class);
        addrsvc=[[addressService alloc] init];
        util=[[Util alloc] init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    [self refreshView];
    mapview.layer.borderColor=[[UIColor blackColor] CGColor];
    mapview.layer.borderWidth=1.0;
}

- (void) refreshView
{
    NSString *fullname=[address.person fullName];
    if( fullname==nil ) fullname=@"No name provided";
    self.navigationItem.title=[address formatSingleline];
    self.addrText.text=[NSString stringWithFormat:@"%@\n%@\n\n",fullname,[address formatMultiline]];
    if( [address.phone length]>0 ) self.addrText.text=[NSString stringWithFormat:@"%@Phone: %@",self.addrText.text,address.phone];
    self.noteText.text=address.notes;
    [mapview removeAnnotations:mapview.annotations];
    [self showPoint:[addrsvc mapPointAnnotationForAddress:address]];
    mapview.showsUserLocation = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showPoint:(MKPointAnnotation *)point
{
    float zoomLevel=0.03;
    MKCoordinateRegion region=MKCoordinateRegionMake(point.coordinate, MKCoordinateSpanMake(zoomLevel,zoomLevel));
    [mapview setRegion: [mapview regionThatFits: region] animated: YES];
    [mapview addAnnotation:point];
}

- (IBAction)unwindToTableViewController:(UIStoryboardSegue *)sender
{
    NSLog(@"Unwinding to table detail view controller.");
    Address *addr=address;
    addressEditViewController *editVC = (addressEditViewController *)sender.sourceViewController;
    [addrsvc edit:addr addr1:editVC.addr1.text addr2:editVC.addr2.text city:editVC.city.text state:editVC.state.text zip:editVC.zip.text phone:editVC.phone.text notes:editVC.notes.text person:editVC.person];
    BOOL hasInternet=[util checkInternet];
    if( hasInternet )
    {
        NSString *fullAddr=[addr formatSingleline];
        NSLog(@"Finding coordinates for: %@",fullAddr);
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:fullAddr
                     completionHandler:^(NSArray* placemarks, NSError* error)
         {
             if (placemarks && placemarks.count > 0)
             {
                 MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:[placemarks objectAtIndex:0]];
                 NSLog(@"Coordinates are: %f, %f", placemark.coordinate.latitude, placemark.coordinate.longitude);
                 addr.latitude=[NSNumber numberWithDouble:placemark.coordinate.latitude];
                 addr.longitude=[NSNumber numberWithDouble:placemark.coordinate.longitude];
                 [addrsvc saveContext];
             }
             else
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Address not found" message: @"That address could not be found on the map!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
             }
         }
         ];
    }
    [self refreshView];
    [editVC dismissViewControllerAnimated:YES completion:nil];
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
