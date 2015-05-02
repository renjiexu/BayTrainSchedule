//
//  Bart.m
//  BayTrainSchedule
//
//  Created by Renjie Xu on 5/1/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "Bart.h"

@implementation Bart

-(NSDictionary *)getSchedule:(BOOL)staticOnly {
    return [self getStaticSchedule];
}

-(NSDictionary *)getStaticSchedule {
    return [super getStaticSchedule:@"bart"];
}

@end
