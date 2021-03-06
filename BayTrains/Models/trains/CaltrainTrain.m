//
//  CaltrainTrain.m
//  BayTrainSchedule
//
//  Created by Renjie Xu on 4/29/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "CaltrainTrain.h"

@interface CaltrainTrain()
@end

@implementation CaltrainTrain


-(NSDictionary *)getSchedule:(BOOL)staticOnly {
    return [self getStaticSchedule];
}

-(NSDictionary *)getStaticSchedule {
    return [super getStaticSchedule:@"caltrain"];
}

@end
