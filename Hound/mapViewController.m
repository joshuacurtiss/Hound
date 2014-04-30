//
//  mapViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 4/30/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "mapViewController.h"

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
    [self pinAddress:@"1100 California St, San Francisco, CA 94108" withTitle:@"Grace Cathedral"];
    [self pinAddress:@"736 Mission St, San Francisco, CA 94103" withTitle:@"Jessie Square"];
    [self pinAddress:@"135 4th St, San Francisco, CA 94103" withTitle:@"Metreon"];
    [self pinAddress:@"747 Howard St, San Francisco, CA 94103" withTitle:@"Moscone Center"];
    
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
                         [self.mapview addAnnotation:point];
                     }
                 }
     ];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
