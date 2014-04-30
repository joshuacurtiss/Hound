//
//  mapViewController.h
//  Hound
//
//  Created by Joshua Curtiss on 4/30/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface mapViewController : UIViewController {
    MKMapView *mapview;
}
@property (nonatomic, retain) IBOutlet MKMapView *mapview;

-(IBAction)setMap:(id)sender;
- (IBAction)getLocation:(id)sender;

@end
