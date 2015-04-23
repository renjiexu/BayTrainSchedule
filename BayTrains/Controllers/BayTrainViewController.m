//
//  BarTrainViewController.m
//  BayTrains
//
//  Created by Renjie Xu on 4/14/15.
//  Copyright (c) 2015 Renjie Xu. All rights reserved.
//

#import "BayTrainViewController.h"
#import "TrainsManager.h"

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
    /*
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        CGRect viewBounds = [self.view bounds];
        viewBounds.origin.y = 18;
        viewBounds.size.height = viewBounds.size.height - 18;
        self.tableView.frame = viewBounds;
    }
    */
    [super viewWillAppear:animated];
}

- (void)loadData {
    NSDictionary* allSchedules = [[TrainsManager getInstance] getAllTrainSchedules];
    [super parseJSON:allSchedules];
}

@end
