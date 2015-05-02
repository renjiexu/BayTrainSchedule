//
//  AmtrakTrain.m
//  BayTrainSchedule
//
//  Created by Renjie Xu on 4/22/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "AmtrakTrain.h"

@interface AmtrakTrain()
@end

@implementation AmtrakTrain


-(NSDictionary *)getSchedule:(BOOL)staticOnly {
    return [self getStaticSchedule];
}

-(NSDictionary *)getStaticSchedule {
    return [super getStaticSchedule:@"amtrak"];
}

@end
