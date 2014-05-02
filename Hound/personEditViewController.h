//
//  personEditViewController.h
//  Hound
//
//  Created by Joshua Curtiss on 4/29/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface personEditViewController : UIViewController
- (IBAction)cancel:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *fname;
@property (strong, nonatomic) IBOutlet UITextField *lname;
@property (strong, nonatomic) IBOutlet UITextView *notes;

@end
