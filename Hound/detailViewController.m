//
//  detailViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 4/29/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "detailViewController.h"
#import "personEditViewController.h"
#import "addressEditViewController.h"
#import "addressDetailViewController.h"
#import "addressService.h"
#import "personService.h"
#import "Person+Setters.h"
#import "Util.h"

@interface detailViewController ()
{
    addressService *addrsvc;
    personService *personsvc;
    Util *util;
}
@end

@implementation detailViewController

@synthesize person, notes, addresses, tableView;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if( self )
    {
        NSLog(@"Init %@.",self.class);
        addrsvc=[[addressService alloc] init];
        personsvc=[[personService alloc] init];
        util=[[Util alloc] init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        NSLog(@"Init %@.",self.class);
        addrsvc=[[addressService alloc] init];
        personsvc=[[personService alloc] init];
        util=[[Util alloc] init];
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
    self.automaticallyAdjustsScrollViewInsets=NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshView];
}

- (void) refreshView
{
    self.navigationItem.title=[person fullName];
    notes.text=person.notes;
    addresses=[NSMutableArray arrayWithObjects:nil];
    for( id item in person.addresses )
    {
        [addresses addObject:item];
    }
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)unwindToTableViewController:(UIStoryboardSegue *)sender
{
    NSString *sourceClass=[NSString stringWithFormat:@"%@",[sender.sourceViewController class]];
    NSLog(@"Unwinding for a %@ view controller.",sourceClass);
    if( [sourceClass isEqualToString:@"personEditViewController"] )
    {
        personEditViewController *editVC = (personEditViewController *)sender.sourceViewController;
        NSString *newname = [NSString stringWithFormat:@"%@ %@",editVC.fname.text,editVC.lname.text] ;
        if( ![newname length]==0 && ![[newname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 )
        {
            [personsvc edit:person firstName:editVC.fname.text lastName:editVC.lname.text notes:editVC.notes.text];
        }
        [self refreshView];
        [editVC dismissViewControllerAnimated:YES completion:nil];
    }
    else if( [sourceClass isEqualToString:@"addressEditViewController"] )
    {
        addressEditViewController *editVC = (addressEditViewController *)sender.sourceViewController;
        Address *newObj=[addrsvc edit:nil addr1:editVC.addr1.text addr2:editVC.addr2.text city:editVC.city.text state:editVC.state.text zip:editVC.zip.text phone:editVC.phone.text notes:editVC.notes.text person:editVC.person];
        BOOL hasInternet=[util checkInternet];
        if( hasInternet )
        {
            [addrsvc findCoordsForAddress:newObj completion:^(BOOL success) {
                if(!success)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Address not found" message: @"That address could not be found on the map!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
        [self refreshView];
        [editVC dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        NSLog(@"Don't know what to do about it.");
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Prepare for segue: %@", [segue identifier]);
    if( [[segue identifier] isEqualToString:@"Update"] )
    {
        personEditViewController *vc = [segue destinationViewController];
        vc.person = person;
    }
    else if( [[segue identifier] isEqualToString:@"New"] )
    {
        addressEditViewController *addrVC = [segue destinationViewController];
        addrVC.person=person;
    }
    else if( [[segue identifier] isEqualToString:@"ViewAddress"] )
    {
        addressDetailViewController *vc = [segue destinationViewController];
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        int row=[myIndexPath row];
        vc.address=[addresses objectAtIndex:row];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [addresses count];
}

- (UITableViewCell *)tableView:(UITableView *)tview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tview dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if( cell==nil )
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    Address *obj=[addresses objectAtIndex:indexPath.row];
    cell.textLabel.text=[obj formatSingleline];
    return cell;
}

- (void) tableView:(UITableView *)tview commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( editingStyle==UITableViewCellEditingStyleDelete )
    {
        [addrsvc del:[addresses objectAtIndex:indexPath.row]];
        [addresses removeObjectAtIndex:indexPath.row];
        [tview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
