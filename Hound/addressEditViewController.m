//
//  addressEditViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 4/30/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "addressEditViewController.h"
#import "Person.h"

@interface addressEditViewController ()
@property (nonatomic, strong) UIPopoverController *popOver;
@end

@implementation addressEditViewController 
@synthesize addr1, addr2, city, state, zip, phone, notes, address, person, name;

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
        addr1.text=address.addr1;
        addr2.text=address.addr2;
        city.text=address.city;
        state.text=address.state;
        zip.text=address.zip;
        phone.text=address.phone;
        notes.text=address.notes;
        Person *p=address.person;
        NSLog(@"%@ %@",address,p);
        if( p!=nil ) [self setNewPerson:p];
    }
    [addr1 becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSArray *txt = [NSArray arrayWithObjects:addr1, addr2, city, state, zip, phone, notes, nil];
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

- (void) setNewPerson:(Person *)newperson
{
    person=newperson;
    [name setTitle:[NSString stringWithFormat:@"%@ %@",person.fname, person.lname] forState:UIControlStateNormal];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Handle phone formatting:
    if( textField==phone )
    {
        if( [textField.text length]==14 && range.length==0 ) return NO; // If full-length, just stop now.
        NSString *num = [self formatNumber:[NSString stringWithFormat:@"%@%@",textField.text,string]];
        int length = [num length];
        if( length<=3 ) textField.text=[NSString stringWithFormat:@"%@",num];
        else if( length<=6 ) textField.text=[NSString stringWithFormat:@"(%@) %@", [num substringToIndex:3], [num substringFromIndex:3]];
        else textField.text=[NSString stringWithFormat:@"(%@) %@-%@", [num substringToIndex:3], [num substringWithRange:NSMakeRange(3, 3)], [num substringWithRange:NSMakeRange(6, [num length]-6)]];
        if( range.length>0 ) return YES; else return NO;
    }
    else if( textField==zip )
    {
        // Just clean the new input, and if it's not a number (meaning new value is length zero), stop it.
        string=[self formatNumber:string];
        if( [string length]==0 && range.length==0 ) return NO;
    }
    // Handle max sizes:
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSArray *txt = [NSArray arrayWithObjects:addr1, addr2, city, state, zip, nil];
    NSArray *txtLen = [NSArray arrayWithObjects:[NSNumber numberWithInt:100], [NSNumber numberWithInt:100], [NSNumber numberWithInt:100], [NSNumber numberWithInt:2], [NSNumber numberWithInt:5], nil];
    for( int i=0 ; i<[txt count] ; i++ ) if( textField==[txt objectAtIndex:i] ) return (newLength>[txtLen[i] integerValue])?NO:YES;
    return YES;
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

- (IBAction)btnName:(id)sender
{
    namePopoverViewController *PopoverView=[[namePopoverViewController alloc] initWithStyle:UITableViewStylePlain];
    PopoverView.personSelected = ^(Person *newperson){
        [self setNewPerson:newperson];
        [self.popOver dismissPopoverAnimated:YES];
    };
    self.popOver =[[UIPopoverController alloc] initWithContentViewController:PopoverView];
    [self.popOver presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    mobileNumber = [[mobileNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    int length = [mobileNumber length];
    if(length > 10) {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    return mobileNumber;
}

@end
