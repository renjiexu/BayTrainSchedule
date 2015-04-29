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

#define InitSelectedIndex @"0"

typedef enum
{
  STTableViewRowInsert,
  STTableViewRowDelete
}STTableViewRowAction;

@interface STTableViewController ()
{
  NSInteger _selectedCategorySection;
  NSMutableArray *_categories;
  NSMutableDictionary *_structure;
  NSMutableArray* _displayedChildren;
}
@property (atomic, assign) NSInteger selectedCategorySection;
@property (nonatomic, strong) NSMutableArray *categories; // index -> category
@property (nonatomic, strong) NSMutableDictionary *structure; // whole logic
@property (nonatomic, strong) NSMutableArray* displayedChildren; // index of categories displayed on screen
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

  [self loadData];
  [self.tableView reloadData];
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
                    @"#ffe800",
                    @"#6ABC8B",
                    @"#d43e19",
                    @"#68DDAB",
                    @"#666F7E"
        ];
    });
    return _textColors;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.displayedChildren.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    STTableViewCell *cell = (STTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[STTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger index = [self getCategoryIndexFrom:indexPath.row];
    STCategory *category = ((STCategory *)[self.categories objectAtIndex:index]);
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
    currentIndex = _selectedCategorySection;
    
    _selectedCategorySection = -1;
    
    [self tableViewBased:currentIndex from:UITableViewRowAnimationTop to:UITableViewRowAnimationFade action:STTableViewRowDelete];
    
    
    NSInteger rootIndex = [self getCategoryIndexFrom:1];
    
    [self.displayedChildren removeAllObjects];
    [self.displayedChildren addObjectsFromArray:[((NSDictionary *)[self.structure objectForKey:@"0"]) objectForKey:@"forwardIndex"]];
    
    movedIndex = [self.displayedChildren indexOfObject:[NSString stringWithFormat:@"%d", (int)rootIndex]];
    if (currentIndex != movedIndex) movedIndex = 0;

    [self tableViewBased:movedIndex from:UITableViewRowAnimationBottom to:UITableViewRowAnimationTop action:STTableViewRowInsert];
    
  }
  else
  {
    if (_selectedCategorySection == index)
    {
      NSLog(@"%@", ((STCategory *)[self.categories objectAtIndex:[self getCategoryIndexFrom:_selectedCategorySection]]).name);
      [self.tableView endUpdates];
      return;
    }
    else
    {
      NSDictionary *categoriesDict =  [self.structure objectForKey:[NSString stringWithFormat:@"%d", (int)categoryIndex]];
      NSArray *forwardCategoryArray = [categoriesDict objectForKey:@"forwardIndex"];
      
      if (_selectedCategorySection == -1)
      {
        _selectedCategorySection = 1;
        
        currentIndex = index;
        [self tableViewBased:currentIndex from:UITableViewRowAnimationBottom to:UITableViewRowAnimationFade action:STTableViewRowDelete];
        
        [self.displayedChildren removeAllObjects];
        [self.displayedChildren addObject:@"0"];
        [self.displayedChildren addObject:[NSString stringWithFormat:@"%d", (int)categoryIndex]];
        
        if (forwardCategoryArray && forwardCategoryArray.count > 0)  [self.displayedChildren addObjectsFromArray:forwardCategoryArray];
        
        movedIndex = _selectedCategorySection;
        
        [self tableViewBased:movedIndex from:UITableViewRowAnimationFade to:UITableViewRowAnimationFade action:STTableViewRowInsert];
        
      }
      else
      {
        NSRange range;
        currentIndex = _selectedCategorySection;
        if (index < _selectedCategorySection)
        {
          range = NSMakeRange(index, self.displayedChildren.count - index);
          _selectedCategorySection = index;
        }
        else
        {
          range = NSMakeRange(_selectedCategorySection + 1, self.displayedChildren.count - _selectedCategorySection - 1);
          [indexPathInsert addObject:[self getIndexPath:_selectedCategorySection]];
          _selectedCategorySection += 1;
        }
        
        [self tableview:self.tableView baseIndexPath:[self getIndexPath:currentIndex] fromIndexPath:[self getIndexPath:range.location] animation:UITableViewRowAnimationNone toIndexPath:[self getIndexPath:range.location + range.length - 1] animation:UITableViewRowAnimationNone tableViewAction:STTableViewRowDelete];
        
        [self.displayedChildren removeObjectsInRange:range];
        
        [self.displayedChildren addObject:[NSString stringWithFormat:@"%d", (int)categoryIndex]];
        
        if (forwardCategoryArray && forwardCategoryArray.count > 0)
        {
          [indexPathInsert addObjectsFromArray:[self indexPathArray:self.displayedChildren.count end:self.displayedChildren.count + forwardCategoryArray.count -1]];
          [self.displayedChildren addObjectsFromArray:forwardCategoryArray];
        }
        movedIndex = _selectedCategorySection;
        [self.tableView insertRowsAtIndexPaths:indexPathInsert withRowAnimation:UITableViewRowAnimationFade];
      }
    }
  }
  if (movedIndex > -1)
  {
    [self.tableView moveRowAtIndexPath:[self getIndexPath:currentIndex] toIndexPath:[self getIndexPath:movedIndex]];
    STCategory *cate = ((STCategory *)[self.categories objectAtIndex:[self getCategoryIndexFrom:movedIndex]]);
    [self setCell:(STTableViewCell *)[self.tableView cellForRowAtIndexPath:[self getIndexPath:currentIndex]] content:cate indexRow:movedIndex];
  }
  
  [self.tableView endUpdates];
  
}

- (void)tableViewBased:(NSInteger)base from:(UITableViewRowAnimation)from to:(UITableViewRowAnimation)to action:(STTableViewRowAction)action
{
  [self tableview:self.tableView baseIndexPath:[self getIndexPath:base] fromIndexPath:[self getIndexPath:0] animation:from toIndexPath:[self getIndexPath:self.displayedChildren.count - 1] animation:to tableViewAction:action];
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
    if (_selectedCategorySection < 0) {
        cell.textLabel.textColor = [UIColor whiteColor];
        [cell.contentView setBackgroundColor:[UIColor colorWithHexString:category.colorHex]];
    }
    else {
        if(indexRow < _selectedCategorySection) {
            cell.textLabel.textColor = [UIColor grayColor];
        }
        else if (indexRow == _selectedCategorySection) {
            cell.textLabel.textColor = [UIColor whiteColor];
            [cell.contentView setBackgroundColor:[UIColor colorWithHexString:category.colorHex]];
        }
    }
    return cell;
}

- (NSInteger) getCategoryIndexFrom:(NSInteger )index
{
  if (self.displayedChildren && self.displayedChildren.count > 0 && index >=0 && index < self.displayedChildren.count)
  {
    return [((NSString *)[self.displayedChildren objectAtIndex:index]) integerValue];
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
    [self loadDataFromLocalJSON];
}

- (void) loadDataFromLocalJSON {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"acerail-static" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    [self parseJSON:[jsonDict objectForKey:@"data"]];
}

- (NSInteger)parseJSON:(NSDictionary *)jsonDict {
    [self reset];
    [self parseJSON:jsonDict backIndex:-1 colorIndex:0];
    _selectedCategorySection = -1;
    [self.displayedChildren addObjectsFromArray:[((NSDictionary *)[self.structure objectForKey:@"0"]) objectForKey:@"forwardIndex"]];
    return -1;
}

- (void)reset {
    self.categories = [[NSMutableArray alloc] init];
    self.structure = [[NSMutableDictionary alloc] init];
    self.displayedChildren = [[NSMutableArray alloc] init];
}

- (NSInteger)parseJSON:(NSDictionary*)jsonDict backIndex:(NSInteger)backIndex colorIndex:(NSInteger)colorIndex {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    STCategory *category = [[STCategory alloc] initWithJSON:jsonDict
                                                           :[[self.class getTextColors] objectAtIndex:colorIndex]];
    [self.categories addObject:category];
  
    NSInteger currentIndex = [self.categories indexOfObject:category];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableArray *jsonArray = [jsonDict objectForKey:@"children"];
    if (jsonArray && jsonArray.count > 0) {
        for (NSDictionary *jsonCategoryDict in jsonArray) {
            colorIndex = (colorIndex + 1) % [[self.class getTextColors] count];
            [array addObject: [NSString stringWithFormat:@"%d", (int)[self parseJSON:jsonCategoryDict backIndex:currentIndex colorIndex:colorIndex]]];
        }
    }
    [dict setObject:[NSString stringWithFormat:@"%d", (int)backIndex] forKey:@"backIndex"];
    if (array && array.count > 0) {
        [dict setObject:array forKey:@"forwardIndex"];
    }
    [self.structure setObject:dict forKey:[NSString stringWithFormat:@"%d",(int)currentIndex]];
    return currentIndex;
}

@end
