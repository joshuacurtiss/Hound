//
//  Person+Setters.m
//  Hound
//
//  Created by Josh Curtiss on 5/15/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "Person+Setters.h"

@implementation Person (Setters)

-(void) setFname:(NSString *)fname {[self setTrimmedValue:fname forKey:@"fname"];}
-(void) setLname:(NSString *)lname {[self setTrimmedValue:lname forKey:@"lname"];}

-(void) setTrimmedValue:(NSString *)newval forKey:(NSString *)key
{
    NSString *trimmedval=[newval stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"Setting %@ to \"%@\".",key,trimmedval);
    [self willChangeValueForKey:key];
    [self setPrimitiveValue:trimmedval forKey:key];
    [self didChangeValueForKey:key];
}

@end
