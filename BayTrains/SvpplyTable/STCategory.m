//
//  STCategory.m
//  SvpplyTable
//
//  Created by Anonymous on 13-8-13.
//  Copyright (c) 2013年 Minqian Liu. All rights reserved.
//

#import "STCategory.h"

@implementation STCategory

@synthesize name, URLString, colorHex;

-(id)initWithJSON:(id)json :(NSString *)textColor {
    NSDictionary *jsonDict = (NSDictionary *)json;
    self = [super init];
    if (self) {
        self.name = [jsonDict objectForKey:@"name"];
        self.URLString = [jsonDict objectForKey:@"url"];
        self.colorHex = textColor;
    }
    return self;
}

@end
