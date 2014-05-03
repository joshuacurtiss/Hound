//
//  mapViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 4/30/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "mapViewController.h"
#import "houndAppDelegate.h"

@interface mapViewController () <MKMapViewDelegate>

@end

@implementation mapViewController
@synthesize mapview;

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
    [self getLoc];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self pinAllAddresses];
}

- (void) pinAllAddresses
{
    houndAppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Address" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *data=[[context executeFetchRequest:request error:&error] mutableCopy];
    [mapview removeAnnotations:mapview.annotations];
    for( int i=0 ; i<[data count] ; i++ )
    {
        NSManagedObject *address=[data objectAtIndex:i];
        NSString *fullAddr=[NSString stringWithFormat:@"%@ %@ %@ %@ %@",[address valueForKey:@"addr1"],[address valueForKey:@"addr2"],[address valueForKey:@"city"],[address valueForKey:@"state"],[address valueForKey:@"zip"]];
        CLLocationCoordinate2D coord=CLLocationCoordinate2DMake( [[address valueForKey:@"latitude"] doubleValue], [[address valueForKey:@"longitude"] doubleValue] );
        [self pinClusterPoint:coord withTitle:fullAddr];
    }
}

- (void) pinAddress:(NSString *)addr withTitle:(NSString *)title
{
    NSString *location = addr;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:location
                 completionHandler:^(NSArray* placemarks, NSError* error)
                 {
                     if (placemarks && placemarks.count > 0)
                     {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                         point.coordinate=placemark.coordinate;
                         point.title=title;
                         point.subtitle=addr;
                         [mapview addAnnotation:point];
                         NSLog(@"Pinned %@.",location);
                     }
                 }
     ];
}

-(MKPointAnnotation *)pinClusterPoint:(CLLocationCoordinate2D)coords withTitle:(NSString *)title
{
    MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
    point.coordinate = coords;
    point.title=title;
    [mapview addAnnotation:point];
    NSLog(@"Pinned %f, %f", point.coordinate.longitude, point.coordinate.latitude);
    return point;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)setMap:(id)sender
{
    switch (((UISegmentedControl *) sender).selectedSegmentIndex) {
        case 0:
            mapview.mapType=MKMapTypeStandard;
            break;
        case 1:
            mapview.mapType=MKMapTypeSatellite;
            break;
        case 2:
            mapview.mapType=MKMapTypeHybrid;
            break;
            
        default:
            break;
    }
}

- (IBAction)getLocation:(id)sender
{
    [self getLoc];
}

-(void)getLoc
{
    mapview.showsUserLocation = YES;
    [mapview setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(self.mapview.userLocation.coordinate, 4000, 4000);
    [mapview setRegion:region animated:YES];
}

-(IBAction)getDirections:(id)sender
{
    NSString *urlString=@"http://maps.apple.com/maps?daddr=40.707184,-73.998392";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

@end
