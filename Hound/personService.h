//
//  personService.h
//  Hound
//
//  Created by Josh Curtiss on 5/24/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person+Setters.h"

@interface personService : NSObject

-(personService *) init;

-(NSArray *) fetch;
-(NSArray *) fetchWithSort:(NSArray *)sortItems;

-(void) del:(Person *)obj;

-(Person *) edit:(Person *)obj
       firstName:(NSString *)fname
        lastName:(NSString *)lname
           notes:(NSString *)notes;

-(BOOL) saveContext;

@end
