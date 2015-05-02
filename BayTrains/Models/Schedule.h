//
//  Schedule.h
//  BayTrainSchedule
//
//  Created by Renjie Xu on 5/2/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Schedule : NSObject

@property (nonatomic) NSInteger selectedCategorySection;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableDictionary *structure;
@property (nonatomic, strong) NSMutableArray* displayedChildren;

@end
