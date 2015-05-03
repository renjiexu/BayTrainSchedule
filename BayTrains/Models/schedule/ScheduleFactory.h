//
//  ScheduleFactory.h
//  BayTrainSchedule
//
//  Created by Renjie Xu on 5/2/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Schedule.h"
#import "Mixpanel.h"

@interface ScheduleFactory : NSObject

+(instancetype)getInstance;

-(Schedule *)buildScheduleByDictionaryData:(NSDictionary *)jsonDict;

@end
