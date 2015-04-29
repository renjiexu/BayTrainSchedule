//
//  BarTrainViewController.m
//  BayTrains
//
//  Created by Renjie Xu on 4/14/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "BayTrainViewController.h"
#import "TrainsManager.h"
#import "ConstantVars.h"

@interface BayTrainViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BayTrainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:REFRESH_SCHEDULE
                                                      object:nil
                                                    queue:nil
                                                usingBlock:^(NSNotification *note) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self loadData:YES];
                                                        [self.tableView reloadData];
                                                    });
                                                }];
}

- (void)loadData {
    [self loadData:NO];
}

- (void)loadData:(BOOL)staticOnly {
    NSDictionary* allSchedules = [[TrainsManager getInstance] getAllTrainSchedules:staticOnly];
    [super parseJSON:allSchedules];
}

@end
