//
//  personService.m
//  Hound
//
//  Created by Josh Curtiss on 5/24/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "personService.h"
#import "houndAppDelegate.h"

@interface personService()
{
    NSManagedObjectContext *context;
}
@end

@implementation personService

-(id)init
{
    houndAppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    context=[appDelegate managedObjectContext];
    NSLog(@"Initialized person service.");
    return self;
}

-(Person *) edit:(Person *)obj
       firstName:(NSString *)fname
        lastName:(NSString *)lname
           notes:(NSString *)notes
{
    if( obj==nil )
    {
        NSLog(@"Creating a new person");
        obj=[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
    }
    else NSLog(@"Editing person");
    [obj setValue:fname forKey:@"fname"];
    [obj setValue:lname forKey:@"lname"];
    [obj setValue:notes forKey:@"notes"];
    [self saveContext];
    return obj;
}

-(void) del:(Person *)obj
{
    NSLog(@"Deleting person");
    [context deleteObject:obj];
    [self saveContext];
}

-(NSArray *) fetch
{
    return [self fetchWithSort:[NSArray arrayWithObjects:nil]];
}

-(NSArray *) fetchWithSort:(NSArray *)sortItems
{
    NSLog(@"Fetching people");
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSMutableArray *sort=[[NSMutableArray alloc] init];
    for( int i=0 ; i<[sortItems count] ; i++ )
        [sort addObject:[NSSortDescriptor sortDescriptorWithKey:sortItems[i] ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    [request setSortDescriptors:sort];
    NSError *error;
    NSArray *data=[context executeFetchRequest:request error:&error];
    if( error ) NSLog(@"Fetch error! %@ %@", error, [error localizedDescription]);
    return data;
}

-(BOOL) saveContext
{
    NSError *error=nil;
    NSLog(@"Save context.");
    BOOL success=[context save:&error];
    if( !success ) NSLog(@"Save failed! %@ %@", error, [error localizedDescription]);
    return success;
}

@end
