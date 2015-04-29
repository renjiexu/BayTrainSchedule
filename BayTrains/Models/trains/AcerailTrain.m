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


@interface AcerailTrain()
@property NSMutableDictionary *staticSchedule;
@property NSMutableDictionary *liveSchedule;
@property NSMutableDictionary *mergedSchedule;
@end

static NSString * const ACERAIL_LIVE_URL = @"http://www.acerail.com/CMSWebParts/ACERail/TrainStatusService.aspx?service=get_vehicles"; //@"http://localhost:3000/json/live_acerail.json";

@implementation AcerailTrain

+(instancetype) getInstance {
    static id instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(NSDictionary *)getSchedule:(BOOL)staticOnly {
    [self getStaticSchedule];
    if (!staticOnly) {
        [self refreshLiveSchedule];
    }
    return self.mergedSchedule;
}

-(NSDictionary *)getStaticSchedule {
    if (!self.staticSchedule) {
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"acerail-static" ofType:@"json"];
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:jsonPath];
        NSError *error = nil;
        NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        self.staticSchedule = [jsonDict objectForKey:@"data"];
        self.mergedSchedule = self.staticSchedule;
    }
    return self.staticSchedule;
}

-(void)refreshLiveSchedule {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:ACERAIL_LIVE_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *transformedSchedule = [self transformJSONFormats:responseObject];
        [self merge:self.staticSchedule :transformedSchedule];
        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_SCHEDULE object:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(NSDictionary *)transformJSONFormats:(NSDictionary*)response {
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

-(id)deepMutableCopy:(id)source
{
    if ([source isKindOfClass:[NSArray class]]) {
        NSArray *oldArray = (NSArray *)source;
        NSMutableArray *newArray = [NSMutableArray array];
        for (id obj in oldArray) {
            [newArray addObject:[self deepMutableCopy:obj]];
        }
        return newArray;
    } else if ([source isKindOfClass:[NSDictionary class]]) {
        NSDictionary *oldDict = source;
        NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
        for (id obj in oldDict) {
            [newDict setObject:[self deepMutableCopy:oldDict[obj]] forKey:obj];
        }
        return newDict;
    } else if ([source isKindOfClass:[NSSet class]]) {
        NSSet *oldSet = (NSSet *)source;
        NSMutableSet *newSet = [NSMutableSet set];
        for (id obj in oldSet) {
            [newSet addObject:[self deepMutableCopy:obj]];
        }
        return newSet;
#if MAKE_MUTABLE_COPIES_OF_NONCOLLECTION_OBJECTS
    } else if ([source conformsToProtocol:@protocol(NSMutableCopying)]) {
        // e.g. NSString
        return [source mutableCopy];
    } else if ([source conformsToProtocol:@protocol(NSCopying)]) {
        // e.g. NSNumber
        return [source copy];
#endif
    } else {
        return source;
    }
}

@end
