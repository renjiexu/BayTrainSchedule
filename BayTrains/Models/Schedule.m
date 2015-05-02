//
//  Schedule.m
//  BayTrainSchedule
//
//  Created by Renjie Xu on 5/2/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "Schedule.h"


@implementation Schedule

- (instancetype)init {
    self.selectedCategorySection = -1;
    self.categories = [[NSMutableArray alloc] init];
    self.structure = [[NSMutableDictionary alloc] init];
    self.displayedChildren = [[NSMutableArray alloc] init];
    return [super init];
}

@end
