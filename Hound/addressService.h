//
//  addressService.h
//  Hound
//
//  Created by Josh Curtiss on 5/18/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Address+Setters.h"

@interface addressService : NSObject

-(addressService *) init;

-(NSArray *) fetch;
-(NSArray *) fetchWithSort:(NSArray *)sortItems;

-(void) del:(Address *)obj;

-(Address *) edit:(Address *)obj
            addr1:(NSString *)addr1
            addr2:(NSString *)addr2
             city:(NSString *)city
            state:(NSString *)state
              zip:(NSString *)zip
            phone:(NSString *)phone
            notes:(NSString *)notes
           person:(Person *)person;

-(BOOL) saveContext;

-(void) findCoordsForAddress:(Address *)addr completion:(void (^)(BOOL success))completion;

-(MKPointAnnotation *) mapPointAnnotationForAddress:(Address *)addr;

@end
