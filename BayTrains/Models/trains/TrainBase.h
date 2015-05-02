//
//  TrainBase.h
//  BayTrainSchedule
//
//  Created by Renjie Xu on 5/1/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrainProtocol.h"

@interface TrainBase : NSObject<TrainProtocol>

@property NSMutableDictionary *staticSchedule;
@property NSMutableDictionary *mergedSchedule;

-(NSDictionary *)getSchedule:(BOOL)staticOnly;

-(NSDictionary *)getStaticSchedule:(NSString *)staticFileName;

@end
