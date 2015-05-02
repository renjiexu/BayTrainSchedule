//
//  ScheduleFactory.m
//  BayTrainSchedule
//
//  Created by Renjie Xu on 5/2/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "ScheduleFactory.h"
#import "STCategory.h"

@implementation ScheduleFactory

+(instancetype)getInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (Schedule *)buildScheduleByDictionaryData:(NSDictionary *)jsonDict {
    Schedule *schedule = [[Schedule alloc] init];
    
    NSMutableArray* backupDisplayedChildren = [schedule.displayedChildren mutableCopy];
    [self parseJSON:schedule :jsonDict backIndex:-1 colorIndex:0];
    if ([backupDisplayedChildren count] != 0) {
        schedule.displayedChildren = backupDisplayedChildren;
    }
    else {
        schedule.selectedCategorySection = -1;
        [schedule.displayedChildren addObjectsFromArray:[((NSDictionary *)[schedule.structure objectForKey:@"0"]) objectForKey:@"forwardIndex"]];
    }
    return schedule;
}

- (NSInteger)parseJSON:(Schedule*)schedule :(NSDictionary*)jsonDict backIndex:(NSInteger)backIndex colorIndex:(NSInteger)colorIndex {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    STCategory *category = [[STCategory alloc] initWithJSON:jsonDict
                                                           :[[self.class getTextColors] objectAtIndex:colorIndex]];
    NSInteger currentIndex = [schedule.categories count];
    [schedule.categories addObject:category];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableArray *jsonArray = [jsonDict objectForKey:@"children"];
    if (jsonArray && jsonArray.count > 0) {
        for (NSDictionary *jsonCategoryDict in jsonArray) {
            colorIndex = (colorIndex + 1) % [[self.class getTextColors] count];
            [array addObject: [NSString stringWithFormat:@"%d", (int)[self parseJSON:schedule :jsonCategoryDict backIndex:currentIndex colorIndex:colorIndex]]];
        }
    }
    [dict setObject:[NSString stringWithFormat:@"%d", (int)backIndex] forKey:@"backIndex"];
    if (array && array.count > 0) {
        [dict setObject:array forKey:@"forwardIndex"];
    }
    [schedule.structure setObject:dict forKey:[NSString stringWithFormat:@"%d",(int)currentIndex]];
    return currentIndex;
}

+ (NSArray *)getTextColors {
    static NSArray *_textColors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _textColors = @[
                        @"#FF5B54",
                        @"#8A4E77",
                        @"#36779D",
                        @"#56B2BD",
                        @"#ead500",
                        @"#6ABC8B",
                        @"#d43e19",
                        @"#ffa54f",
                        @"#68DDAB",
                        @"#666F7E"
                        ];
    });
    return _textColors;
}

@end
