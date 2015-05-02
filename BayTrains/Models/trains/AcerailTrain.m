//
//  AcerailTrain.m
//  BayTrainSchedule
//
//  Created by Renjie Xu on 4/21/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "AcerailTrain.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "ConstantVars.h"
#import "NSObject+Category.h"


static NSString * const ACERAIL_LIVE_URL = @"http://www.acerail.com/CMSWebParts/ACERail/TrainStatusService.aspx?service=get_vehicles"; //@"http://localhost:3000/json/live_acerail.json";

@implementation AcerailTrain

-(NSDictionary *)getStaticSchedule {
    return [super getStaticSchedule:@"acerail"];
}

-(void)refreshLiveSchedule {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:ACERAIL_LIVE_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *transformedSchedule = [self extractLiveScheduleFromLiveResponse:responseObject];
        if (transformedSchedule == nil) {
            self.mergedSchedule = [self.staticSchedule copy];
        }
        else {
            [self merge:self.staticSchedule :transformedSchedule];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_SCHEDULE object:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(NSDictionary *)extractLiveScheduleFromLiveResponse:(NSDictionary*)response {
    if (response == nil) {
        return nil;
    }
    NSMutableDictionary *transformedSchedule = nil;
    for (NSDictionary *train in [response objectForKey:@"get_vehicles"]) {
        NSString *scheduleNumber = [train objectForKey:@"scheduleNumber"];
        if ([scheduleNumber isEqualToString:@"NIS"]) {
            continue;
        }
        for (NSDictionary *stop in [train objectForKey:@"minutesToNextStops"]) {
            NSNumber *stopID = [stop objectForKey:@"stopID"];
            NSString *liveTime = [stop objectForKey:@"time"];
            if ([liveTime isEqualToString:@""]) {
                continue;
            }
            if (transformedSchedule == nil) {
                transformedSchedule = [[NSMutableDictionary alloc] init];
            }
            if ([transformedSchedule objectForKey:stopID] == nil) {
                [transformedSchedule setObject:[[NSMutableDictionary alloc] init] forKey:stopID];
            }
            [[transformedSchedule objectForKey:stopID] setObject:liveTime forKey:scheduleNumber];
        }
    }
    return transformedSchedule;
}


-(NSDictionary *)merge :(NSDictionary *)staticSchedule :(NSDictionary *)liveSchedule {
    if (liveSchedule == nil) {
        return staticSchedule;
    }
    //TODO: is there a way to avoid pre-copying???
    self.mergedSchedule = [self deepMutableCopy:self.staticSchedule];
    for (NSMutableDictionary *direction in [self.mergedSchedule objectForKey:@"children"]) {
        for (NSMutableDictionary *stop in [direction objectForKey:@"children"]) {
            for (NSMutableDictionary *train in [stop objectForKey:@"children"]) {
                NSString *trainNo = [train objectForKey:@"trainNo"];
                NSString *liveTime = [[liveSchedule objectForKey:[stop objectForKey:@"stopID"]] objectForKey:trainNo];
                if (liveTime == nil) {
                    continue;
                }
                if (![[train objectForKey:@"name"] isEqualToString:liveTime]) {
                    NSLog(@"Update %@: %@:  %@ to %@", [stop objectForKey:@"name"], trainNo, [train objectForKey:@"name"], liveTime);
                    [train setValue:liveTime forKey:@"name"];
                }
            }
        }
    }
    return self.mergedSchedule;
}

@end
