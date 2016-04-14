//
//  JYTableViewCell.h
//  03-scrollCell
//
//  Created by 乐校 on 16/4/14.
//  Copyright © 2016年 lexiao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JYTableViewCellNotificationChangeToUnexpanded @"JYTableViewCellNotificationChangeToUnexpanded"

typedef NS_ENUM(NSInteger, JYTableViewCellState) {
    JYTableViewCellStateUnexpanded = 0, // cell状态关闭
    JYTableViewCellStateExpanded, // cell状态打开
};
@class JYTableViewCell;

@protocol JYTableViewCellDelegate <NSObject>

- (void)buttonTouchedOnCell:(JYTableViewCell *)cell
                atIndexPath:(NSIndexPath *)indexPath
              atButtonIndex:(NSInteger)buttonIndex;

@end

@interface JYTableViewCell : UITableViewCell
{
    JYTableViewCellState _state;
}
/** 当前Cell的状态 */
@property (nonatomic,assign) JYTableViewCellState state;
/** 当前的tablview */
@property (nonatomic,assign) UITableView *tableView;
/** 右划显示btn的背景视图 */
@property (nonatomic,strong) UIView *buttonsView;
/** 每个cell上的右划ScrollView */
@property (nonatomic,strong) UIScrollView *scrollView;
/** cell的contentView */
@property (nonatomic,strong) UIView *cellContentView;
/** 右划编辑的代理 */
@property (nonatomic,assign) id<JYTableViewCellDelegate> delegate;
/** 按钮的标题 */
@property (nonatomic,copy) NSArray *rightButtonTitles;
/** 下面这些都是我的需求有需要自行改变 */
@property (nonatomic, strong) NSString *nameStr;
@property (nonatomic, strong) NSString *addressStr;
@property (nonatomic, strong) NSString *phoneStr;
/** 单元格样式 */
@property (nonatomic, strong) NSString *cellType;
/**
 *  自定义Cell
 *
 *  @param style             cell的样式
 *  @param reuseIdentifier   cell的重用标示符
 *  @param delegate          JYTableViewCellDelegate代理
 *  @param tableView         tableView
 *  @param rightButtonTitles 右边按钮的标题数组
 *  @param rightButtonColors 右边按钮的背景颜色数组
 *
 *  @return 返回cell
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                     delegate:(id<JYTableViewCellDelegate>)delegate
                  inTableView:(UITableView*)tableView
                 withRowHight:(CGFloat)rowHeight
        withRightButtonTitles:(NSArray*)rightButtonTitles
        withRightButtonColors:(NSArray *)rightButtonColors;

@end
