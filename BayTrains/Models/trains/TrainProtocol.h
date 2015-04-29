//
//  TrainProtocol.h
//  BayTrainSchedule
//
//  Created by Renjie Xu on 4/26/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TrainProtocol <NSObject>

-(NSDictionary *)getSchedule:(BOOL)staticOnly;

@optional
-(NSDictionary *)getStaticSchedule;

@optional
-(void)refreshLiveSchedule;

@end
