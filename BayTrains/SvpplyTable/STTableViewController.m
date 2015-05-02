//
//  STTableViewController.m
//  SvpplyTable
//
//  Created by Anonymous on 13-8-13.
//  Copyright (c) 2013年 Minqian Liu. All rights reserved.
//

#import "STTableViewController.h"
#import "STTableViewCell.h"
#import "UIColor+HexString.h"
#import "Schedule.h"
#import "ScheduleFactory.h"

#define InitSelectedIndex @"0"

typedef enum
{
  STTableViewRowInsert,
  STTableViewRowDelete
}STTableViewRowAction;

@interface STTableViewController ()
/*
{
  NSInteger _selectedCategorySection;
  NSMutableArray *_categories;
  NSMutableDictionary *_structure;
  NSMutableArray* _displayedChildren;
}
*/

@end

@implementation STTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reset];
  
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor blackColor]];

    self.schedule = [[Schedule alloc] init];
    [self loadData];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.schedule.displayedChildren.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    STTableViewCell *cell = (STTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[STTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger index = [self getCategoryIndexFrom:indexPath.row];
    STCategory *category = ((STCategory *)[self.schedule.categories objectAtIndex:index]);
    cell = [self setCell:cell content:category indexRow:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self setArraysWithSelected:indexPath.row];
}

#pragma mark - Animation Methods

- (void)setArraysWithSelected:(NSInteger)index
{
  NSMutableArray *indexPathInsert = [[NSMutableArray alloc] init];
  
  NSInteger categoryIndex = [self getCategoryIndexFrom:index];
  
  NSInteger currentIndex = -1, movedIndex = -1;
  
  [self.tableView beginUpdates];
  
  if (index == 0 && categoryIndex == 0)
  {
    currentIndex = self.schedule.selectedCategorySection;
    
    self.schedule.selectedCategorySection = -1;
    
    [self tableViewBased:currentIndex from:UITableViewRowAnimationTop to:UITableViewRowAnimationFade action:STTableViewRowDelete];
    
    
    NSInteger rootIndex = [self getCategoryIndexFrom:1];
    
    [self.schedule.displayedChildren removeAllObjects];
    [self.schedule.displayedChildren addObjectsFromArray:[((NSDictionary *)[self.schedule.structure objectForKey:@"0"]) objectForKey:@"forwardIndex"]];
    
    movedIndex = [self.schedule.displayedChildren indexOfObject:[NSString stringWithFormat:@"%d", (int)rootIndex]];
    if (currentIndex != movedIndex) movedIndex = 0;

    [self tableViewBased:movedIndex from:UITableViewRowAnimationBottom to:UITableViewRowAnimationTop action:STTableViewRowInsert];
    
  }
  else
  {
    if (self.schedule.selectedCategorySection == index) {
        NSLog(@"%@", ((STCategory *)[self.schedule.categories objectAtIndex:[self getCategoryIndexFrom:self.schedule.selectedCategorySection]]).name);
        [self.tableView endUpdates];
        return;
    }
    else {
      NSDictionary *categoriesDict =  [self.schedule.structure objectForKey:[NSString stringWithFormat:@"%d", (int)categoryIndex]];
      NSArray *forwardCategoryArray = [categoriesDict objectForKey:@"forwardIndex"];
      
      if (self.schedule.selectedCategorySection == -1)
      {
        self.schedule.selectedCategorySection = 1;
        
        currentIndex = index;
        [self tableViewBased:currentIndex from:UITableViewRowAnimationBottom to:UITableViewRowAnimationFade action:STTableViewRowDelete];
        
        [self.schedule.displayedChildren removeAllObjects];
        [self.schedule.displayedChildren addObject:@"0"];
        [self.schedule.displayedChildren addObject:[NSString stringWithFormat:@"%d", (int)categoryIndex]];
        
        if (forwardCategoryArray && forwardCategoryArray.count > 0)  [self.schedule.displayedChildren addObjectsFromArray:forwardCategoryArray];
        
        movedIndex = self.schedule.selectedCategorySection;
        
        [self tableViewBased:movedIndex from:UITableViewRowAnimationFade to:UITableViewRowAnimationFade action:STTableViewRowInsert];
        
      }
      else
      {
        NSRange range;
        currentIndex = self.schedule.selectedCategorySection;
        if (index < self.schedule.selectedCategorySection)
        {
          range = NSMakeRange(index, self.schedule.displayedChildren.count - index);
          self.schedule.selectedCategorySection = index;
        }
        else
        {
          range = NSMakeRange(self.schedule.selectedCategorySection + 1, self.schedule.displayedChildren.count - self.schedule.selectedCategorySection - 1);
          [indexPathInsert addObject:[self getIndexPath:self.schedule.selectedCategorySection]];
          self.schedule.selectedCategorySection += 1;
        }
        
        [self tableview:self.tableView baseIndexPath:[self getIndexPath:currentIndex] fromIndexPath:[self getIndexPath:range.location] animation:UITableViewRowAnimationNone toIndexPath:[self getIndexPath:range.location + range.length - 1] animation:UITableViewRowAnimationNone tableViewAction:STTableViewRowDelete];
        
        [self.schedule.displayedChildren removeObjectsInRange:range];
        
        [self.schedule.displayedChildren addObject:[NSString stringWithFormat:@"%d", (int)categoryIndex]];
        
        if (forwardCategoryArray && forwardCategoryArray.count > 0)
        {
          [indexPathInsert addObjectsFromArray:[self indexPathArray:self.schedule.displayedChildren.count end:self.schedule.displayedChildren.count + forwardCategoryArray.count -1]];
          [self.schedule.displayedChildren addObjectsFromArray:forwardCategoryArray];
        }
        movedIndex = self.schedule.selectedCategorySection;
        [self.tableView insertRowsAtIndexPaths:indexPathInsert withRowAnimation:UITableViewRowAnimationFade];
      }
    }
  }
  if (movedIndex > -1)
  {
    [self.tableView moveRowAtIndexPath:[self getIndexPath:currentIndex] toIndexPath:[self getIndexPath:movedIndex]];
    STCategory *cate = ((STCategory *)[self.schedule.categories objectAtIndex:[self getCategoryIndexFrom:movedIndex]]);
    [self setCell:(STTableViewCell *)[self.tableView cellForRowAtIndexPath:[self getIndexPath:currentIndex]] content:cate indexRow:movedIndex];
  }
  
  [self.tableView endUpdates];
  
}

- (void)tableViewBased:(NSInteger)base from:(UITableViewRowAnimation)from to:(UITableViewRowAnimation)to action:(STTableViewRowAction)action
{
  [self tableview:self.tableView baseIndexPath:[self getIndexPath:base] fromIndexPath:[self getIndexPath:0] animation:from toIndexPath:[self getIndexPath:self.schedule.displayedChildren.count - 1] animation:to tableViewAction:action];
}

- (void)tableview:(UITableView *)tableView baseIndexPath:(NSIndexPath *)baseIndexPath fromIndexPath:(NSIndexPath *)fromIndexPath animation:(UITableViewRowAnimation)baseTofromAnimation toIndexPath:(NSIndexPath *)toIndexPath animation:(UITableViewRowAnimation)baseTotoAnimation tableViewAction:(STTableViewRowAction)action
{
  NSMutableArray *array = [[NSMutableArray alloc]init];
  array = [self indexPathArray:fromIndexPath.row end:baseIndexPath.row - 1];
  [self tableView:tableView action:action indexPathArray:array animation:baseTofromAnimation];
  array = [self indexPathArray:baseIndexPath.row + 1 end:toIndexPath.row];
  [self tableView:tableView action:action indexPathArray:array animation:baseTotoAnimation];
}

- (void)tableView:(UITableView *)tableView action:(STTableViewRowAction)action indexPathArray:(NSArray *)indexPathArray animation:(UITableViewRowAnimation)animation
{
  if (STTableViewRowInsert == action )
  {
    [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:animation];
  }
  else if (STTableViewRowDelete == action)
  {
    [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:animation];
  }
}

#pragma mark - Private Methods

- (STTableViewCell *)setCell:(STTableViewCell *)cell content:(STCategory *)category indexRow:(NSInteger)indexRow {
    [cell setContent:category];
    if (self.schedule.selectedCategorySection < 0) {
        cell.textLabel.textColor = [UIColor whiteColor];
        [cell.contentView setBackgroundColor:[UIColor colorWithHexString:category.colorHex]];
    }
    else {
        if(indexRow < self.schedule.selectedCategorySection) {
            cell.textLabel.textColor = [UIColor grayColor];
        }
        else if (indexRow == self.schedule.selectedCategorySection) {
            cell.textLabel.textColor = [UIColor whiteColor];
            [cell.contentView setBackgroundColor:[UIColor colorWithHexString:category.colorHex]];
        }
    }
    return cell;
}

- (NSInteger) getCategoryIndexFrom:(NSInteger )index
{
  if (self.schedule.displayedChildren && self.schedule.displayedChildren.count > 0 && index >=0 && index < self.schedule.displayedChildren.count)
  {
    return [((NSString *)[self.schedule.displayedChildren objectAtIndex:index]) integerValue];
  }
  return 0;
}

- (NSMutableArray *)indexPathArray:(NSInteger)begin end:(NSInteger)end
{
  NSMutableArray *indexPathArray = [[NSMutableArray alloc]init];
  for (NSInteger i = begin; i <= end; i++) {
    [indexPathArray addObject:[self getIndexPath:i]];
  }
  return indexPathArray;
}

- (NSIndexPath *)getIndexPath:(NSInteger)row
{
  return [NSIndexPath indexPathForRow:row inSection:0];
}

#pragma mark - Load Data Methods

- (void)loadData {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"acerail" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    self.schedule = [[ScheduleFactory getInstance] parseJSON:[jsonDict objectForKey:@"data"]];
}


- (void)reset {
    self.schedule = [[Schedule alloc] init];
}



@end
