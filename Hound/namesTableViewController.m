//
//  namesTableViewController.m
//  Hound
//
//  Created by Joshua Curtiss on 4/29/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "namesTableViewController.h"
#import "personEditViewController.h"
#import "detailViewController.h"
#import "personService.h"

@interface namesTableViewController ()
{
    NSMutableDictionary *dataDict;
    NSArray *sectionTitles;
    Person *myNewPerson;
    personService *personsvc;
}
@end

@implementation namesTableViewController
@synthesize data;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        personsvc=[[personService alloc] init];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        personsvc=[[personService alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem=self.editButtonItem;
    //[self.tabBarController setSelectedIndex:3]; // Debugging line to go straight to a particular view. Left for reference.
}

- (void) viewWillAppear:(BOOL)animated
{
    [self refreshTable];
}

- (void) refreshTable
{
    NSLog(@"Reloading data and refreshing the table.");
    data=[[personsvc fetchWithSort:[NSArray arrayWithObjects:@"lname",@"fname", nil]] mutableCopy];
    dataDict=[[NSMutableDictionary alloc] init];
    for( int i=0 ; i<data.count ; i++ )
    {
        Person *p=data[i];
        NSString *letter = [p.lname substringToIndex:1];
        if( !dataDict[letter] ) dataDict[letter]=[NSMutableArray arrayWithObjects:nil];
        [dataDict[letter] addObject:p];
    }
    sectionTitles=[[dataDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *secTitle=sectionTitles[section];
    NSArray *sec=dataDict[secTitle];
    return sec.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sectionTitles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *secTitle=sectionTitles[indexPath.section];
    NSArray *sec=dataDict[secTitle];
    if( cell==nil )
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    Person *person=sec[indexPath.row];
    cell.textLabel.text=[person fullNameLastFirst];
    return cell;
}

- (IBAction)unwindToTableViewController:(UIStoryboardSegue *)sender
{
    NSLog(@"Unwinding to table view controller.");
    personEditViewController *editVC = (personEditViewController *)sender.sourceViewController;
    NSString *newname = [NSString stringWithFormat:@"%@ %@",editVC.fname.text,editVC.lname.text] ;
    if( ![newname length]==0 && ![[newname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 )
    {
        Person *newPerson=[personsvc edit:nil firstName:editVC.fname.text lastName:editVC.lname.text notes:editVC.notes.text];
        myNewPerson=newPerson;
    }
    [self refreshTable];
    [editVC dismissViewControllerAnimated:YES completion:^
     {
         [self performSegueWithIdentifier:@"Show" sender:myNewPerson];
     }];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( editingStyle==UITableViewCellEditingStyleDelete )
    {
        NSString *secTitle=sectionTitles[indexPath.section];
        NSArray *sec=dataDict[secTitle];
        Person *p=sec[indexPath.row];
        [personsvc del:p];
        [dataDict[secTitle] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *senderClass=[NSString stringWithFormat:@"%@",[sender class]];
    if( [[segue identifier] isEqualToString:@"Show"] )
    {
        detailViewController *detailVC = [segue destinationViewController];
        if( [senderClass isEqualToString:@"Person"] )
        {
            detailVC.person=(Person *)sender;
        }
        else
        {
            NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
            NSString *secTitle=sectionTitles[myIndexPath.section];
            NSArray *sec=dataDict[secTitle];
            detailVC.person = sec[myIndexPath.row];
        }
    }
}

@end
