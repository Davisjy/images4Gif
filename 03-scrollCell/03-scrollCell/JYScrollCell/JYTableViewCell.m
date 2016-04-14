//
//  JYTableViewCell.m
//  03-scrollCell
//
//  Created by 乐校 on 16/4/14.
//  Copyright © 2016年 lexiao. All rights reserved.
//

#import "JYTableViewCell.h"
#import "Masonry.h"

#define JYTableViewCellButtonWidth 40.0f
#define JYTableViewCellNotificationEnableScroll @"JYTableViewCellNotificationEnableScroll"
#define JYTableViewCellNotificationUnenableScroll @"JYTableViewCellNotificationUnenableScroll"

#define KScreenHeight [UIScreen mainScreen].bounds.size.height
#define KScreenWidth [UIScreen mainScreen].bounds.size.width

#define BLACK_333333 [UIColor colorWithRed:((float)((0x333333 & 0xFF0000) >> 16))/255.0 green:((float)((0x333333 & 0xFF00) >> 8))/255.0 blue:((float)(0x333333 & 0xFF))/255.0 alpha:1.0]//内容列表字体颜色
#define GRAY_666666 [UIColor colorWithRed:((float)((0x666666 & 0xFF0000) >> 16))/255.0 green:((float)((0x666666 & 0xFF00) >> 8))/255.0 blue:((float)(0x666666 & 0xFF))/255.0 alpha:1.0]//灰色


@interface JYTableViewCell () <UIScrollViewDelegate>
{
    UIPanGestureRecognizer *_panGesture;
}
/** 本次需求中的属性就不解释了 */
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UIImageView *checkImgView;
@end

@implementation JYTableViewCell
//正在修改的cell
static JYTableViewCell *_editingCell;

/**
 *  自定义Cell
 *
 *  @param style             cell的样式
 *  @param reuseIdentifier   cell的重用标示符
 *  @param delegate          JYTableViewCellDelegate代理
 *  @param tableView         tableView
 *  @param rowHeight         每一行cell的高度
 *  @param rightButtonTitles 右边按钮的标题数组
 *  @param rightButtonColors 右边按钮的背景颜色数组
 *
 *  @return 返回cell
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                     delegate:(id<JYTableViewCellDelegate>)delegate
                  inTableView:(UITableView *)tableView
                 withRowHight:(CGFloat)rowHeight
        withRightButtonTitles:(NSArray*)rightButtonTitles
        withRightButtonColors:(NSArray *)rightButtonColors
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.tableView = tableView;
        self.delegate = delegate;
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, rowHeight)];
        _scrollView.contentSize = CGSizeMake(KScreenWidth + JYTableViewCellButtonWidth * (rightButtonTitles.count), rowHeight);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView addSubview:_scrollView];
        
        //右边的Btn
        self.rightButtonTitles = rightButtonTitles;
        CGFloat leftButtonViewWidth = JYTableViewCellButtonWidth * self.rightButtonTitles.count;
        _buttonsView = [[UIView alloc]initWithFrame:CGRectMake(KScreenWidth-leftButtonViewWidth, 0,
                                                               leftButtonViewWidth, rowHeight)];
        [self.scrollView addSubview:_buttonsView];
        
        NSArray *imgStrArr = @[@"地址编辑", @"地址删除"] ;
        
        CGFloat buttonWidth = 40; //ZFTableViewCellButtonWidth;
        CGFloat buttonHeight = rowHeight - 10;
        for (int a = 0; a < self.rightButtonTitles.count; a++) {
            CGFloat left = a * (JYTableViewCellButtonWidth);
            UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(left, 10, buttonWidth,buttonHeight)];
            button.tag = a;
            button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            //            button.backgroundColor = rightButtonColors[a];
            [button setBackgroundImage:[UIImage imageNamed:imgStrArr[a]] forState:UIControlStateNormal];
            //            [button setTitle:self.rightButtonTitles[a] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
            [_buttonsView addSubview:button];
        }
        
        // 背景随机色
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, KScreenWidth - 10, rowHeight - 10)];
        
        bgView.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bgView.bounds byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerBottomLeft) cornerRadii:CGSizeMake(5, 5)];
        layer.path = path.CGPath;
        bgView.layer.mask = layer;
        
        //cell的内容部分
        CGRect cellContentViewFrame = CGRectMake(5, 0, KScreenWidth - 10, rowHeight - 10);
        _cellContentView = [[UIView alloc]initWithFrame:cellContentViewFrame];
        _cellContentView.backgroundColor = [UIColor whiteColor];
        UIImage *image;
        if ([self.cellType isEqualToString:@"1"]) {
            image = [UIImage imageNamed:@"速递地址勾选"];
        } else {
            image = [UIImage imageNamed:@"速递地址选择框"];
        }
        //        UIImageView *checkImageView = [[UIImageView alloc] initWithImage:image];
        UIImageView *checkImageView = [[UIImageView alloc] init];
        checkImageView.image = image;
        
        [_cellContentView addSubview:checkImageView];
        [checkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_cellContentView).offset(15);
            make.top.equalTo(_cellContentView).offset(15);
            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];
        self.checkImgView = checkImageView;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        [_cellContentView addSubview:nameLabel];
        self.nameLabel = nameLabel;
        //        nameLabel.text = @"你看你看";
        nameLabel.text = self.nameStr;
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.textColor = BLACK_333333;
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(checkImageView.mas_right).offset(20);
            make.top.equalTo(_cellContentView).offset(15);
        }];
        
        UILabel *addresLabel = [[UILabel alloc] init];
        self.addressLabel = addresLabel;
        [_cellContentView addSubview:addresLabel];
        addresLabel.textColor = GRAY_666666;
        addresLabel.font = [UIFont systemFontOfSize:12];
        //        addresLabel.text = @"黄鹤楼603宿舍";
        addresLabel.text = self.addressStr;
        [addresLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel);
            make.bottom.equalTo(_cellContentView).offset(-15);
        }];
        
        UILabel *phoneLabel = [[UILabel alloc] init];
        self.phoneLabel = phoneLabel;
        [_cellContentView addSubview:phoneLabel];
        //        phoneLabel.text = @"15638857701";
        phoneLabel.text = self.phoneStr;
        phoneLabel.font = [UIFont systemFontOfSize:12];
        phoneLabel.textColor = GRAY_666666;
        [phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_cellContentView).offset(18);
            make.right.equalTo(_cellContentView).offset(-35);
        }];
        
        
        [bgView addSubview:_cellContentView];
        //        [_scrollView addSubview:_cellContentView];
        [_scrollView addSubview:bgView];
        
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapGesture:)];
        [self.cellContentView addGestureRecognizer:tapGesture];
        
        ///外部通知，把cell改为原来的状态
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationChangeToUnexpanded:) name:JYTableViewCellNotificationChangeToUnexpanded object:nil];
        ///内部通知所有的cell可以滚动scrollView了
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationEnableScroll:) name:JYTableViewCellNotificationEnableScroll object:nil];
        ///内部通知所有的cell不可以滚动scrollView(除当前编辑的这个外)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUnenableScroll:) name:JYTableViewCellNotificationUnenableScroll object:nil];
    }
    return self;
}

- (void)setNameStr:(NSString *)nameStr
{
    _nameStr = nameStr;
    self.nameLabel.text = nameStr;
}

- (void)setAddressStr:(NSString *)addressStr
{
    _addressStr = addressStr;
    self.addressLabel.text = addressStr;
}

- (void)setPhoneStr:(NSString *)phoneStr
{
    _phoneStr = phoneStr;
    self.phoneLabel.text = phoneStr;
}

- (void)setCellType:(NSString *)cellType
{
    _cellType = cellType;
    UIImage *image;
    if ([cellType isEqualToString:@"1"]) {
        image = [UIImage imageNamed:@"速递地址勾选"];
    } else {
        image = [UIImage imageNamed:@"速递地址选择框"];
    }
    self.checkImgView.image = image;
    self.checkImgView.userInteractionEnabled = YES;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)prepareForReuse{
    [super prepareForReuse];
    [self.scrollView setContentOffset:CGPointZero];
    //self.state=ZFTableViewCellStateUnexpanded;///不需要设置为这个状态
}
#pragma mark - Properties
-(void)setState:(JYTableViewCellState)state{
    _state = state;
    if (state == JYTableViewCellStateExpanded){
        self.scrollView.contentOffset = CGPointMake(self.buttonsView.frame.size.width, 0);
        
        //        self.tableView.scrollEnabled = NO;
        //        self.tableView.allowsSelection = NO;
        _editingCell = self;
        
        _buttonsView.transform = CGAffineTransformMakeTranslation(_scrollView.contentOffset.x, 0);
        
        ///通知所有的cell停止滚动(除自己这个)
        [[NSNotificationCenter defaultCenter] postNotificationName:JYTableViewCellNotificationUnenableScroll object:nil];
        
        ///往tableView上添加一个手势处理,使得在tableView上的拖动也只是影响当前这个cell的scrollView
        if (!_panGesture){
            _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onPanGesture:)];
            [self.tableView addGestureRecognizer:_panGesture];
        }
    }
    else if(state == JYTableViewCellStateUnexpanded){
        ///停止tableView的手势
        if (_panGesture){
            [self.tableView removeGestureRecognizer:_panGesture];
            _panGesture = nil;
        }
        
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //            self.tableView.userInteractionEnabled = YES;
        });
        ///
        [self.scrollView setContentOffset:CGPointZero animated:YES];
        ///tableView可以滚动了
        //        _editingCell = nil;
        //通知所有的cell可以滚动
        [[NSNotificationCenter defaultCenter] postNotificationName:JYTableViewCellNotificationEnableScroll object:nil];
    }
    
}
- (JYTableViewCellState)state{
    return _state;
}
#pragma mark - Action
-(void)onButton:(id)sender{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:self];
    UIButton* button = (UIButton*)sender;
    if ([self.delegate respondsToSelector:@selector(buttonTouchedOnCell:atIndexPath:atButtonIndex:)]){
        [self.delegate buttonTouchedOnCell:self atIndexPath:indexPath atButtonIndex:button.tag];
    }
}
#pragma mark - Gesture
-(void)onTapGesture:(UITapGestureRecognizer*)recognizer{
       if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]){
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:self];
        [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:cellIndexPath];
    }
}
-(void)onPanGesture:(UIPanGestureRecognizer*)recognizer{
    if (!_editingCell)
        return;
    if (recognizer.state == UIGestureRecognizerStateChanged){
        CGFloat translate_x = [recognizer translationInView:_editingCell.tableView].x;
        CGFloat offset_x = self.buttonsView.frame.size.width;
        CGFloat move_offset_x = offset_x-translate_x;
        [_editingCell.scrollView setContentOffset:CGPointMake(move_offset_x, 0)];
        
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded||
             recognizer.state == UIGestureRecognizerStateCancelled ||
             recognizer.state == UIGestureRecognizerStateFailed){
        _editingCell.state = JYTableViewCellStateUnexpanded;
    }
}
#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.buttonsView.transform = CGAffineTransformMakeTranslation(scrollView.contentOffset.x, 0);
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentOffset.x > self.buttonsView.frame.size.width/2){
        self.state = JYTableViewCellStateExpanded;
    }
    else{
        self.state = JYTableViewCellStateUnexpanded;
    }
}
#pragma mark - Notififcation
//外部通知，把cell改为原来的状态
-(void)notificationChangeToUnexpanded:(NSNotification*)notification{
    self.state = JYTableViewCellStateUnexpanded;
}
//内部通知所有的cell可以滚动scrollView了
-(void)notificationEnableScroll:(NSNotification*)notification{
    self.scrollView.scrollEnabled = YES;
}
//内部通知所有的cell不可以滚动scrollView(除当前编辑的这个外)
-(void)notificationUnenableScroll:(NSNotification*)notification{
    if (_editingCell != self) {
        self.scrollView.scrollEnabled = NO;
        self.state = JYTableViewCellStateUnexpanded;
    }
}


@end
