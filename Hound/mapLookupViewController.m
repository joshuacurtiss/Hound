//
//  mapLookupViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 5/3/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "mapLookupViewController.h"
#import <AddressBook/AddressBook.h>

@interface mapLookupViewController () <MKMapViewDelegate, UISearchBarDelegate>

@end

@implementation mapLookupViewController
@synthesize mapview, searchbar, txtAddress, txtCoordinates;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mapview.layer.borderWidth=1.0;
    searchbar.layer.borderWidth=1.0;
    [self getLoc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search for: %@",searchBar.text);
    NSString *fullAddr=searchBar.text;
    // Handle geocoding:
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:fullAddr completionHandler:^(NSArray* placemarks, NSError* error)
     {
         if (placemarks && placemarks.count > 0)
         {
             // Remove existing annotations:
             [mapview removeAnnotations:mapview.annotations];
             // Get coordinates:
             CLPlacemark *topResult = [placemarks objectAtIndex:0];
             MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
             NSLog(@"Coordinates are: %f, %f", placemark.coordinate.longitude, placemark.coordinate.latitude);
             txtCoordinates.text=[NSString stringWithFormat:@"%f, %f", placemark.coordinate.longitude, placemark.coordinate.latitude];
             // Pin map:
             [mapview addAnnotation:placemark];
             MKCoordinateRegion region = MKCoordinateRegionMake(placemark.coordinate, MKCoordinateSpanMake(0.03,0.03));
             [mapview setRegion:[mapview regionThatFits:region] animated:YES];
             // Handle address:
             NSArray *formattedAddressLines=[placemark.addressDictionary valueForKey:@"FormattedAddressLines"];
             NSString *formattedAddress=@"";
             for( int i=0 ; i<formattedAddressLines.count ; i++ )
             {
                 formattedAddress=[NSString stringWithFormat:@"%@%@\n",formattedAddress,formattedAddressLines[i]];
             }
             txtAddress.text=formattedAddress;
             // Dismiss keyboard:
             [searchBar resignFirstResponder];
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Address not found" message: @"That address could not be found on the map!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
         }
     }
     ];
}

-(void)getLoc
{
    mapview.showsUserLocation = YES;
    [mapview setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(self.mapview.userLocation.coordinate, 4000, 4000);
    [mapview setRegion:region animated:YES];
}

@end
