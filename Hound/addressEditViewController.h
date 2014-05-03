//
//  addressEditViewController.h
//  Hound
//
//  Created by Joshua Curtiss on 4/30/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "namePopoverViewController.h"

@interface addressEditViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *addr1;
@property (strong, nonatomic) IBOutlet UITextField *addr2;
@property (strong, nonatomic) IBOutlet UITextField *city;
@property (strong, nonatomic) IBOutlet UITextField *state;
@property (strong, nonatomic) IBOutlet UITextField *zip;
@property (strong, nonatomic) IBOutlet UITextField *phone;
@property (strong, nonatomic) IBOutlet UILabel *phoneTypeLabel;
@property (strong, nonatomic) IBOutlet UITextView *notes;
@property (strong, nonatomic) IBOutlet UIButton *name;
@property (strong) NSManagedObject *address;
@property (strong) NSManagedObject *person;
- (IBAction)cancel:(id)sender;
- (IBAction)btnName:(id)sender;
- (void) setNewPerson:(NSManagedObject *)newperson;
@end
