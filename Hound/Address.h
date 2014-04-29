//
//  Address.h
//  Hound
//
//  Created by Josh Curtiss on 4/29/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * addr1;
@property (nonatomic, retain) NSString * addr2;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * phoneType;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSManagedObject *person;

@end
