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
#import "MJRefresh.h"

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
    
    self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self configurePullDownRefresh];
    
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

- (void)configurePullDownRefresh {
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(pullDownRefresh)];
    [self.tableView.header setTitle:@"Pull down to refresh" forState:MJRefreshHeaderStateIdle];
    [self.tableView.header setTitle:@"Release to refresh" forState:MJRefreshHeaderStatePulling];
    [self.tableView.header setTitle:@"Loading ..." forState:MJRefreshHeaderStateRefreshing];
    self.tableView.header.updatedTimeHidden = YES;
}

- (void)loadData {
    [self loadData:NO];
}

- (void)pullDownRefresh {
    [self loadData:NO];
    [self.tableView reloadData];
    [self.tableView.legendHeader endRefreshing];
}

- (void)loadData:(BOOL)staticOnly {
    TrainsManager *trainsManager = [TrainsManager getInstance];
    NSDictionary* allSchedules = [trainsManager getAllTrainSchedules:staticOnly];
    Schedule *newSchedule = [[ScheduleFactory getInstance] buildScheduleByDictionaryData:allSchedules];
    if (self.schedule.selectedCategorySection != -1) {
        newSchedule.selectedCategorySection = self.schedule.selectedCategorySection;
        newSchedule.displayedChildren = self.schedule.displayedChildren;
    }
    self.schedule = newSchedule;
}

@end
