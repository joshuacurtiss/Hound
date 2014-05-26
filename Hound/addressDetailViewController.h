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
#import "Person.h"

@interface addressDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *addrText;
@property (strong, nonatomic) IBOutlet UITextView *noteText;
@property (strong) Address *address;
@property (strong, nonatomic) IBOutlet MKMapView *mapview;
- (IBAction)setMap:(id)sender;
@end
