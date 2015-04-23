//
//  TrainsManager.m
//  BayTrainSchedule
//
//  Created by Renjie Xu on 4/22/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "TrainsManager.h"
#import "AmtrakTrain.h"
#import "AcerailTrain.h"

@implementation TrainsManager

+(instancetype) getInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(NSDictionary *)getAllTrainSchedules {
    NSDictionary *allTrainsScheduleDict = [[NSMutableDictionary alloc] init];
    NSArray *schedulesArray = [[NSMutableArray alloc] initWithObjects:
                               [AcerailTrain getSchedule],
                               [AmtrakTrain getSchedule],
                               nil];
    [allTrainsScheduleDict setValue:@"All Trains" forKey:@"name"];
    [allTrainsScheduleDict setValue:schedulesArray forKey:@"children"];
    return allTrainsScheduleDict;
}


@end
