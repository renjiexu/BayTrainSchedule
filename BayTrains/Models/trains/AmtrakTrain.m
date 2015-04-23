//
//  AmtrakTrain.m
//  BayTrainSchedule
//
//  Created by Renjie Xu on 4/22/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "AmtrakTrain.h"

@implementation AmtrakTrain

+(NSDictionary *)getSchedule {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"amtrak-static" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    return [jsonDict objectForKey:@"data"];
}

@end
