//
//  Util.m
//  Hound
//
//  Created by Josh Curtiss on 5/24/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "Util.h"

@implementation Util

- (BOOL) checkInternet
{
    
    NSData *internetData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com/m"]];
    BOOL hasInternet=(internetData.length)?YES:NO;
    NSLog(@"Device is connected to the internet? %hhd", hasInternet);
    return hasInternet;
}

@end
