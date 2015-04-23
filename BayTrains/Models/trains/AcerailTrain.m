//
//  AcerailTrain.m
//  BayTrainSchedule
//
//  Created by Renjie Xu on 4/21/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "AcerailTrain.h"

@implementation AcerailTrain

+(NSDictionary *)loadStaticSchedule {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"acerail" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    return [jsonDict objectForKey:@"data"];
}

@end
