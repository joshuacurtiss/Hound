//
//  addressEditViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 4/30/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "addressEditViewController.h"

@interface addressEditViewController ()

@end

@implementation addressEditViewController

@synthesize addr1, addr2, city, state, zip, phone, notes, address;

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
    notes.layer.cornerRadius = 8.0f;
    notes.layer.masksToBounds = NO;
    notes.layer.borderWidth = .5f;
    notes.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    if( address!=nil )
    {
        addr1.text=[address valueForKey:@"addr1"];
        addr2.text=[address valueForKey:@"addr2"];
        city.text=[address valueForKey:@"city"];
        state.text=[address valueForKey:@"state"];
        zip.text=[address valueForKey:@"zip"];
        phone.text=[address valueForKey:@"phone"];
        notes.text=[address valueForKey:@"notes"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
