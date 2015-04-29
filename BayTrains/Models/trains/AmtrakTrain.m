//
//  AmtrakTrain.m
//  BayTrainSchedule
//
//  Created by Renjie Xu on 4/22/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "AmtrakTrain.h"

@interface AmtrakTrain()
@property (nonatomic, strong) NSDictionary *staticSchedule;
@end

@implementation AmtrakTrain

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
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"amtrak" ofType:@"json"];
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:jsonPath];
        NSError *error = nil;
        NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        self.staticSchedule = [jsonDict objectForKey:@"data"];
    }
    return self.staticSchedule;
}

@end
