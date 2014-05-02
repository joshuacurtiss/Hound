//
//  addressDetailViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 5/1/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "addressDetailViewController.h"

@interface addressDetailViewController ()

@end

@implementation addressDetailViewController

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
    self.navigationItem.title=_detail[0];
    self.addr1.text=_detail[0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
