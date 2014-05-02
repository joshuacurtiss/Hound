//
//  detailViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 4/29/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "detailViewController.h"
#import "personEditViewController.h"
#import "houndAppDelegate.h"

@interface detailViewController ()
@end

@implementation detailViewController

@synthesize person;

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
    [self refreshView];
}

- (void) refreshView
{
    NSString *fullName=[NSString stringWithFormat:@"%@ %@",[person valueForKey:@"fname"],[person valueForKey:@"lname"]];
    self.navigationItem.title=fullName;
    self.nameLabel.text=fullName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)unwindToTableViewController:(UIStoryboardSegue *)sender
{
    NSLog(@"Unwinding to detail view controller.");
    personEditViewController *editVC = (personEditViewController *)sender.sourceViewController;
    NSString *newname = [NSString stringWithFormat:@"%@ %@",editVC.fname.text,editVC.lname.text] ;
    if( ![newname length]==0 && ![[newname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 )
    {
        houndAppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        [person setValue:editVC.fname.text forKey:@"fname"];
        [person setValue:editVC.lname.text forKey:@"lname"];
        [person setValue:editVC.notes.text forKey:@"notes"];
        NSError *error=nil;
        if( ![context save:&error] ) NSLog(@"Save failed! %@ %@",error, [error localizedDescription]);
    }
    [self refreshView];
    [editVC dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Prepare for segue: %@", [segue identifier]);
    if( [[segue identifier] isEqualToString:@"Update"] )
    {
        personEditViewController *vc = [segue destinationViewController];
        vc.person = person;
    }
}

@end
