//
//  Table_CollectionVC.m
//  Linkage
//
//  Created by m2ciMAC-2 on 2017/9/11.
//  Copyright © 2017年 LeeJay. All rights reserved.
//

#import "Table_CollectionVC.h"
#import "CollectionCategoryModel.h"
#import "CollectionViewCell.h"
#import "CollectionViewController.h"
#import "CollectionViewHeaderView.h"
#import "LJCollectionViewFlowLayout.h"
#import "LeftTableViewCell.h"
//#import "MJDIYBackFooter.h"
//#import "MJDIYHeader.h"

static float kLeftTableViewWidth = 80.f;
static float kCollectionViewMargin = 3.f;

@interface Table_CollectionVC ()<UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIScrollViewDelegate>{
    CGFloat     _contentOffsetY;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *collectionDatas;

@property (nonatomic, strong) LJCollectionViewFlowLayout *flowLayout;


@end

@implementation Table_CollectionVC
{
    NSInteger _selectIndex;
    BOOL _isScrollDown;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _selectIndex = 0;
    _contentOffsetY = 0;
    _isScrollDown = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.collectionView];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.tableView.frame), 0, 1, SCREEN_HEIGHT - 64)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"liwushuo" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSArray *categories = dict[@"data"][@"categories"];
    for (NSDictionary *dict in categories)
    {
        CollectionCategoryModel *model =
        [CollectionCategoryModel objectWithDictionary:dict];
        [self.dataSource addObject:model];
        
        NSMutableArray *datas = [NSMutableArray array];
        for (SubCategoryModel *sModel in model.subcategories)
        {
            [datas addObject:sModel];
        }
        [self.collectionDatas addObject:datas];
    }
    
    [self.tableView reloadData];
    [self.collectionView reloadData];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                animated:YES
                          scrollPosition:UITableViewScrollPositionNone];
    
}

#pragma mark - Getters

- (NSMutableArray *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableArray *)collectionDatas
{
    if (!_collectionDatas)
    {
        _collectionDatas = [NSMutableArray array];
    }
    return _collectionDatas;
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kLeftTableViewWidth, SCREEN_HEIGHT)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.rowHeight = 55;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorColor = [UIColor clearColor];
        [_tableView registerClass:[LeftTableViewCell class] forCellReuseIdentifier:kCellIdentifier_Left];
    }
    return _tableView;
}

- (LJCollectionViewFlowLayout *)flowLayout
{
    if (!_flowLayout)
    {
        _flowLayout = [[LJCollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _flowLayout.minimumInteritemSpacing = 2;
        _flowLayout.minimumLineSpacing = 2;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kCollectionViewMargin + kLeftTableViewWidth, kCollectionViewMargin, SCREEN_WIDTH - kLeftTableViewWidth - 2 * kCollectionViewMargin, SCREEN_HEIGHT - 2 * kCollectionViewMargin - 64) collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        _collectionView.alwaysBounceVertical = YES;
        //注册cell
        [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier_CollectionView];
        //注册分区头标题
        [_collectionView registerClass:[CollectionViewHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"CollectionViewHeaderView"];
        
//         self.collectionView.mj_footer = [MJDIYBackFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMeizi)];
//         self.collectionView.mj_header = [MJDIYHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshMeizi)];
        
    }
    return _collectionView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Left forIndexPath:indexPath];
    CollectionCategoryModel *model = self.dataSource[indexPath.row];
    cell.name.text = model.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectIndex = indexPath.row;
    
    [self refreshCollectionDataWithIndexPath:indexPath];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_selectIndex inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - UICollectionView DataSource Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    CollectionCategoryModel *model = self.dataSource[_selectIndex];
    return model.subcategories.count;

//    return 1;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_CollectionView forIndexPath:indexPath];
    CollectionCategoryModel *model = self.dataSource[_selectIndex];
    cell.model = model.subcategories[indexPath.item];
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((SCREEN_WIDTH - kLeftTableViewWidth - 4 * kCollectionViewMargin) / 3,
                      (SCREEN_WIDTH - kLeftTableViewWidth - 4 * kCollectionViewMargin) / 3 + 30);
}

// 当拖动CollectionView的时候，处理TableView
- (void)selectRowAtIndexPath:(NSInteger)index
{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - UIScrollView Delegate
// 标记一下CollectionView的滚动方向，是向上还是向下
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static float lastOffsetY = 0;
    
    if (self.collectionView == scrollView)
    {
        _isScrollDown = lastOffsetY < scrollView.contentOffset.y;
        lastOffsetY = scrollView.contentOffset.y;
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (self.collectionView == scrollView)
    {
        NSLog(@"contenOffset===%f",scrollView.contentOffset.y);
        
        _contentOffsetY = scrollView.contentOffset.y;
        
        if (scrollView.contentOffset.y >= 85) {
            
            [self loadMoreMeizi];
            
        }
        if (scrollView.contentOffset.y <= -85) {
            
             [self refreshMeizi];
            
        }
    }
    
}

- (void)refreshMeizi{
    
    if (_selectIndex) {
        _selectIndex -= 1;
        
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(kCollectionViewMargin + kLeftTableViewWidth, _contentOffsetY, SCREEN_WIDTH - kLeftTableViewWidth - 2 * kCollectionViewMargin, SCREEN_HEIGHT - 2 * kCollectionViewMargin - 64)];
        
        [self.view addSubview:imgV];
        //    imgV.backgroundColor = ZLRandomColor;
        
        imgV.image = [self imageFromView:self.collectionView];
        
        [self.collectionView reloadData];
        
        self.collectionView.frame = CGRectMake(kCollectionViewMargin + kLeftTableViewWidth, -(SCREEN_HEIGHT - 2 * kCollectionViewMargin) - 64, SCREEN_WIDTH - kLeftTableViewWidth - 2 * kCollectionViewMargin, SCREEN_HEIGHT - 2 * kCollectionViewMargin - 64);
        
        [self selectRowAtIndexPath:_selectIndex];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            imgV.frame = CGRectMake(kCollectionViewMargin + kLeftTableViewWidth,  SCREEN_HEIGHT + (SCREEN_HEIGHT - 2 * kCollectionViewMargin)  , SCREEN_WIDTH - kLeftTableViewWidth - 2 * kCollectionViewMargin, SCREEN_HEIGHT - 2 * kCollectionViewMargin - 64);
            
            self.collectionView.frame = CGRectMake(kCollectionViewMargin + kLeftTableViewWidth, kCollectionViewMargin, SCREEN_WIDTH - kLeftTableViewWidth - 2 * kCollectionViewMargin, SCREEN_HEIGHT - 2 * kCollectionViewMargin - 64);
            
        } completion:^(BOOL finished) {
            
            [imgV removeFromSuperview];
            
            [self selectRowAtIndexPath:_selectIndex];
            
        }];
        
    }
    
}

- (void)loadMoreMeizi{
    
    
    if (_selectIndex == self.dataSource.count - 1) {
        return;
    }

    _selectIndex += 1;

    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(kCollectionViewMargin + kLeftTableViewWidth, -_contentOffsetY-kCollectionViewMargin, SCREEN_WIDTH - kLeftTableViewWidth - 2 * kCollectionViewMargin, SCREEN_HEIGHT - 2 * kCollectionViewMargin - 64)];
    [self.view addSubview:imgV];
    
//    imgV.backgroundColor = ZLRandomColor;
    
    imgV.image = [self imageFromView:self.collectionView];
    
    [self.collectionView reloadData];
    
    self.collectionView.frame = CGRectMake(kCollectionViewMargin + kLeftTableViewWidth,  SCREEN_HEIGHT + (SCREEN_HEIGHT - 2 * kCollectionViewMargin)  , SCREEN_WIDTH - kLeftTableViewWidth - 2 * kCollectionViewMargin, SCREEN_HEIGHT - 2 * kCollectionViewMargin - 64);
    
    [self selectRowAtIndexPath:_selectIndex];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        imgV.frame = CGRectMake(kCollectionViewMargin + kLeftTableViewWidth,  -(SCREEN_HEIGHT - 2 * kCollectionViewMargin)  , SCREEN_WIDTH - kLeftTableViewWidth - 2 * kCollectionViewMargin, SCREEN_HEIGHT - 2 * kCollectionViewMargin - 64);
        
        self.collectionView.frame = CGRectMake(kCollectionViewMargin + kLeftTableViewWidth, kCollectionViewMargin, SCREEN_WIDTH - kLeftTableViewWidth - 2 * kCollectionViewMargin, SCREEN_HEIGHT - 2 * kCollectionViewMargin - 64);
        
    } completion:^(BOOL finished) {
        
        [imgV removeFromSuperview];
    }];
    
}

- (void)refreshCollectionDataWithIndexPath:(NSIndexPath *)indexPath{
    
    [self.collectionView reloadData];
    
}

- (UIImage *)imageFromView: (UIView *) theView
{
    
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

@end
