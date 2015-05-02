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
#import "CaltrainTrain.h"
#import "Bart.h"

@interface TrainsManager()
@property AcerailTrain *acerail;
@property AmtrakTrain *amtrak;
@property CaltrainTrain *caltrain;
@property Bart *bart;
@end


@implementation TrainsManager

+(instancetype) getInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        ((TrainsManager *)sharedInstance).acerail = [[AcerailTrain alloc] init];
        ((TrainsManager *)sharedInstance).amtrak = [[AmtrakTrain alloc] init];
        ((TrainsManager *)sharedInstance).caltrain = [[CaltrainTrain alloc] init];
        ((TrainsManager *)sharedInstance).bart = [[Bart alloc] init];
    });
    return sharedInstance;
}

-(NSDictionary *)getAllTrainSchedules:(BOOL)staticOnly {
    NSDictionary *allTrainsScheduleDict = [[NSMutableDictionary alloc] init];
    NSArray *schedulesArray = [[NSMutableArray alloc] initWithObjects:
                               [self.acerail getSchedule:staticOnly],
                               [self.amtrak getSchedule:staticOnly],
                               [self.caltrain getSchedule:staticOnly],
                               [self.bart getSchedule:staticOnly],
                               nil];
    [allTrainsScheduleDict setValue:@"All Trains" forKey:@"name"];
    [allTrainsScheduleDict setValue:schedulesArray forKey:@"children"];
    return allTrainsScheduleDict;
}


@end
