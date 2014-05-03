//
//  personEditViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 4/29/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "personEditViewController.h"

@interface personEditViewController ()

@end

@implementation personEditViewController

@synthesize fname, lname, notes, person;

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
    if( person!=nil )
    {
        fname.text=[person valueForKey:@"fname"];
        lname.text=[person valueForKey:@"lname"];
        notes.text=[person valueForKey:@"notes"];
    }
    [fname becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSArray *txt = [NSArray arrayWithObjects:fname, lname, notes, nil];
    for( int i=0 ; i<[txt count] ; i++ )
    {
        if( textField == [txt objectAtIndex:i] )
        {
            [textField resignFirstResponder];
            if( i<[txt count] ) [[txt objectAtIndex:i+1] becomeFirstResponder];
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSArray *txt = [NSArray arrayWithObjects:fname, lname, nil];
    NSArray *txtLen = [NSArray arrayWithObjects:[NSNumber numberWithInt:50],[NSNumber numberWithInt:80], nil];
    for( int i=0 ; i<[txt count] ; i++ ) if( textField==[txt objectAtIndex:i] ) return (newLength>[txtLen[i] integerValue])?NO:YES;
    return YES;
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
