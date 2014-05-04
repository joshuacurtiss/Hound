//
//  mapLookupViewController.h
//  Hound
//
//  Created by Joshua Curtiss on 5/3/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface mapLookupViewController : UIViewController {
    MKMapView *mapview;
}
@property (strong, nonatomic) IBOutlet MKMapView *mapview;
@property (strong, nonatomic) IBOutlet UISearchBar *searchbar;
@property (strong, nonatomic) IBOutlet UITextField *txtCoordinates;
@property (strong, nonatomic) IBOutlet UITextView *txtAddress;
@end
