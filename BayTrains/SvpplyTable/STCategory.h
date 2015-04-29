//
//  STCategory.h
//  SvpplyTable
//
//  Created by Anonymous on 13-8-13.
//  Copyright (c) 2013年 Minqian Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STCategory : NSObject
{
    NSString* name;
	NSString* URLString;
	NSString* colorHex;
    NSString* trainNo;
    NSNumber* stopID;
}

@property(strong, nonatomic) NSString* colorHex;
@property(strong, nonatomic) NSString* URLString;
@property(strong, nonatomic) NSString* name;
@property(strong, nonatomic) NSString* trainNo;
@property(strong, nonatomic) NSNumber * stopID;

-(id)initWithJSON:(id)json :(NSString *)textColor;

@end
