//
//  addressDetailViewController.h
//  Hound
//
//  Created by Joshua Curtiss on 5/1/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Address.h"

@interface addressDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *addr1;
@property (strong) Address *address;
@property (strong, nonatomic) IBOutlet MKMapView *mapview;
@end
