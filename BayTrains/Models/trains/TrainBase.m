//
//  TrainBase.m
//  BayTrainSchedule
//
//  Created by Renjie Xu on 5/1/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "TrainBase.h"
#import "NSObject+Category.h"

@interface TrainBase()

@end

@implementation TrainBase

-(NSDictionary *)getSchedule:(BOOL)staticOnly {
    [self getStaticSchedule];
    if (!staticOnly) {
        [self refreshLiveSchedule];
    }
    return self.mergedSchedule;
}

-(NSDictionary *)getStaticSchedule:(NSString *)staticFileName {
    if (!self.staticSchedule) {
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:staticFileName ofType:@"json"];
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:jsonPath];
        NSError *error = nil;
        NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        self.staticSchedule = [jsonDict objectForKey:@"data"];
        self.mergedSchedule = self.staticSchedule;
    }
    return self.staticSchedule;
}

@end
