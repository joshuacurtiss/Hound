//
//  mapViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 4/30/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "mapViewController.h"
#import "addressService.h"
#import "Address+Setters.h"
#import "Person+Setters.h"

@interface mapViewController () <MKMapViewDelegate>
{
    addressService *addrsvc;
}
@end

@implementation mapViewController
@synthesize mapview;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self)
    {
        NSLog(@"Init %@.",self.class);
        addrsvc=[[addressService alloc] init];
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
    NSArray *data=[addrsvc fetch];
    [mapview removeAnnotations:mapview.annotations];
    for( int i=0 ; i<[data count] ; i++ )
    {
        Address *address=[data objectAtIndex:i];
        if( [address.latitude doubleValue]!=0.0 && [address.longitude doubleValue]!=0.0 )
        {
            NSLog(@"Pinning %@, %@", address.latitude, address.longitude);
            [mapview addAnnotation:[addrsvc mapPointAnnotationForAddress:address]];
        }
    }
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

@end
