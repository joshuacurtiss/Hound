//
//  addressService.m
//  Hound
//
//  Created by Josh Curtiss on 5/18/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "addressService.h"
#import "houndAppDelegate.h"
#import "Person+Setters.h"

@interface addressService()
{
    NSManagedObjectContext *context;
}
@end

@implementation addressService

-(id)init
{
    houndAppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    context=[appDelegate managedObjectContext];
    NSLog(@"Initialized address service.");
    return self;
}

-(Address *) edit:(Address *)obj
            addr1:(NSString *)addr1
            addr2:(NSString *)addr2
             city:(NSString *)city
            state:(NSString *)state
              zip:(NSString *)zip
            phone:(NSString *)phone
            notes:(NSString *)notes
           person:(Person *)person
{
    if( obj==nil )
    {
        NSLog(@"Creating a new address");
        obj=[NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:context];
    }
    else NSLog(@"Editing address");
    [obj setValue:addr1 forKey:@"addr1"];
    [obj setValue:addr2 forKey:@"addr2"];
    [obj setValue:city forKey:@"city"];
    [obj setValue:state forKey:@"state"];
    [obj setValue:zip forKey:@"zip"];
    [obj setValue:phone forKey:@"phone"];
    [obj setValue:notes forKey:@"notes"];
    [obj setValue:person forKey:@"person"];
    [self saveContext];
    return obj;
}

-(void) del:(Address *)obj
{
    NSLog(@"Deleting address");
    [context deleteObject:obj];
    [self saveContext];
}

-(NSArray *) fetch
{
    return [self fetchWithSort:[NSArray arrayWithObjects:nil]];
}

-(NSArray *) fetchWithSort:(NSArray *)sortItems
{
    NSLog(@"Fetching addresses");
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Address" inManagedObjectContext:context];
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

-(MKPointAnnotation *) mapPointAnnotationForAddress:(Address *)addr
{
    CLLocationCoordinate2D coord=CLLocationCoordinate2DMake([addr.latitude doubleValue],[addr.longitude doubleValue]);
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    NSString *personName=[addr.person fullName];
    if( personName==nil ) personName=@"No Name";
    point.coordinate=coord;
    point.title=personName;
    point.subtitle=[addr formatSingleline];
    return point;
}

@end
