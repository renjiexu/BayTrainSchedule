//
//  STTableViewController.h
//  SvpplyTable
//
//  Created by Anonymous on 13-8-13.
//  Copyright (c) 2013年 Minqian Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STCategory.h"
#import "Schedule.h"
#import "ScheduleFactory.h"

@interface STTableViewController : UITableViewController
<
  UITableViewDataSource,
  UITableViewDelegate
>

@property (atomic, strong) Schedule *schedule;

- (void)loadData;

@end
