//
//  AmtrakTrain.h
//  BayTrainSchedule
//
//  Created by Renjie Xu on 4/22/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrainProtocol.h"

@interface AmtrakTrain : NSObject<TrainProtocol>

+(instancetype)getInstance;

@end
