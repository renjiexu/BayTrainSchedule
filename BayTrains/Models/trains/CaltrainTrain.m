//
//  CaltrainTrain.m
//  BayTrainSchedule
//
//  Created by Renjie Xu on 4/29/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "CaltrainTrain.h"

@interface CaltrainTrain()
@property (nonatomic, strong) NSDictionary *staticSchedule;
@end

@implementation CaltrainTrain

+(instancetype) getInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(NSDictionary *)getSchedule:(BOOL)staticOnly {
    return [self getStaticSchedule];
}

-(NSDictionary *)getStaticSchedule {
    if (self.staticSchedule == nil) {
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"caltrain" ofType:@"json"];
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:jsonPath];
        NSError *error = nil;
        NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        self.staticSchedule = [jsonDict objectForKey:@"data"];
    }
    return self.staticSchedule;
}

@end
