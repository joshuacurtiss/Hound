//
//  Address+Setters.m
//  Hound
//
//  Created by Josh Curtiss on 5/15/14.
//  Copyright (c) 2014 Cranky Bit. All rights reserved.
//

#import "Address+Setters.h"

@implementation Address (Setters)

-(void)setAddr1:(NSString *)addr1 {[self setTrimmedValue:addr1 forKey:@"addr1"];}
-(void)setAddr2:(NSString *)addr2 {[self setTrimmedValue:addr2 forKey:@"addr2"];}
-(void)setCity:(NSString *)city {[self setTrimmedValue:city forKey:@"city"];}

-(void) setTrimmedValue:(NSString *)newval forKey:(NSString *)key
{
    NSString *trimmedval=[newval stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"Setting %@ to \"%@\".",key,trimmedval);
    [self willChangeValueForKey:key];
    [self setPrimitiveValue:trimmedval forKey:key];
    [self didChangeValueForKey:key];
}

- (NSString *) formatMultiline
{
    NSString *out=[NSString stringWithFormat:@"%@\n",[self trimString:self.addr1]];
    if( [[self trimString:self.addr2] length]>0 ) out=[NSString stringWithFormat:@"%@%@\n",out,[self trimString:self.addr2]];
    if( [[self trimString:self.city] length]>0 ) out=[NSString stringWithFormat:@"%@%@",out,[self trimString:self.city]];
    if( [[self trimString:self.state] length]>0 || [[self trimString:self.zip] length]>0 )
        out=[NSString stringWithFormat:@"%@, %@",out,[self trimString:[NSString stringWithFormat:@"%@ %@",self.state,self.zip]]];
    return out;
}

- (NSString *) formatSingleline
{
    NSString *out=[self trimString:self.addr1];
    if( [[self trimString:self.addr2] length]>0 ) out=[NSString stringWithFormat:@"%@ %@",out,[self trimString:self.addr2]];
    if( [[self trimString:self.city] length]>0 ) out=[NSString stringWithFormat:@"%@, %@",out,[self trimString:self.city]];
    if( [[self trimString:self.state] length]>0 || [[self trimString:self.zip] length]>0 ) out=[NSString stringWithFormat:@"%@, %@",out,[self trimString:[NSString stringWithFormat:@"%@ %@",self.state,self.zip]]];
    return out;
}

- (NSString *) trimString:(NSString *)str
{
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
