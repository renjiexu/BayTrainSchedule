//
//  NSObject+Category.m
//  BayTrainSchedule
//
//  Created by Renjie Xu on 4/29/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "NSObject+Category.h"

@implementation NSObject (Category)

-(id)deepMutableCopy:(id)source {
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
