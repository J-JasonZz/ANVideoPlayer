//
//  ANPlayerViewController.m
//  ANVideoPlayer
//
//  Created by JasonZhang on 16/9/9.
//  Copyright © 2016年 wscn. All rights reserved.
//

#import "ANPlayerModel.h"
#import "ANVideoPlayerUtil.h"
#import "ANPlayerTableViewCell.h"
#import "ANPlayerViewController.h"

#define KANPlayerTableViewCellReuseID @"ANPlayerTableViewCellReuseID"

@interface ANPlayerViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ANPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configTableView];
    
    [self requestData];
}

- (void)configTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ANPlayerTableViewCell" bundle:nil] forCellReuseIdentifier:KANPlayerTableViewCellReuseID];
}

- (void)requestData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"videoData" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    self.dataSource = [NSMutableArray array];
    NSArray *videoList = [rootDict objectForKey:@"videoList"];
    for (NSDictionary *dataDic in videoList) {
        ANPlayerModel *model = [[ANPlayerModel alloc] init];
        model.playUrl = dataDic[@"playUrl"];
        model.coverImageUrl = dataDic[@"coverForFeed"];
        model.title = dataDic[@"title"];
        [self.dataSource addObject:model];
    }
    
    [self.tableView reloadData];
}

#pragma mark -- UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ANPlayerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KANPlayerTableViewCellReuseID];
    ANPlayerModel *model = self.dataSource[indexPath.row];
    [cell assginValueWithPlayerModel:model];
    
    cell.playButtonClick = ^{
        [[ANVideoPlayerUtil shareUtil] playVideoWithStreamURL:[NSURL URLWithString:model.playUrl] isLive:NO];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 240.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
