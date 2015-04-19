//
//  NetworkUtil.m
//  BayTrains
//
//  Created by Renjie Xu on 4/16/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "NetworkUtil.h"
#import "AFNetworking.h"

static NSString * const BaseURLString = @"http://localhost:3000/json/acerail.json";

@implementation NetworkUtil

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}




@end
