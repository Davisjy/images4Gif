//
//  JYStatusBar.m
//  02-statusBarNotification
//
//  Created by 乐校 on 16/4/14.
//  Copyright © 2016年 lexiao. All rights reserved.
//

#import "JYStatusBar.h"
#import "CBAutoScrollLabel.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface JYStatusBar ()
@property (nonatomic, strong) UIWindow *overlayWindow;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIImageView *arrawMark;
@property (nonatomic, strong) CBAutoScrollLabel *scrollLabel;
@end

@implementation JYStatusBar

+ (JYStatusBar *)sharedView
{
    static dispatch_once_t onceToken;
    static JYStatusBar *statusBar;
    dispatch_once(&onceToken, ^{
        statusBar = [[JYStatusBar alloc] init];
    });
    return statusBar;
}

- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    //添加滚动完成后的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollComplete) name:@"StatusBarScrollComplete" object:nil];
    return self;
}

//滚动完成
- (void)scrollComplete
{
    [self dismiss];
}

- (void)didMoveToSuperview
{
    self.overlayWindow.center = CGPointMake(self.overlayWindow.center.x, self.overlayWindow.center.y-10);
    [UIView animateWithDuration:0.5 animations:^{
        
        self.overlayWindow.center=CGPointMake(self.overlayWindow.center.x, self.overlayWindow.center.y+10);
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)showWithText:(NSString *)text barColor:(UIColor *)barColor textColor:(UIColor *)textColor
{
    if(!self.superview)
    [self.overlayWindow addSubview:self];
    [self.overlayWindow setHidden:NO];
    [self.topBar setHidden:NO];
    [self.arrow setHidden:NO];
    self.topBar.backgroundColor = barColor;
    self.backgroundColor = [UIColor blueColor];
    self.scrollLabel.hidden = NO;
    self.scrollLabel.text = text;
    self.scrollLabel.textColor = textColor;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = self.topBar.bounds;
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar addSubview:btn];
    
//    [self performSelector:@selector(dismiss) withObject:nil afterDelay:4];
}

- (void)btnClick
{
    if (_click) {
        _click();
    }
    [self dismiss];
    NSLog(@"点击了");
    
}

- (void)dismiss
{
    [UIView animateWithDuration:0.4 animations:^{

    } completion:^(BOOL finished) {
        [self.topBar removeFromSuperview];
        self.topBar = nil;
        [self.overlayWindow removeFromSuperview];
        self.overlayWindow = nil;
        self.arrawMark = nil;
    }];
}

#pragma mark - 懒加载
- (UIWindow *)overlayWindow {
    if(!_overlayWindow) {
        _overlayWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        _overlayWindow.backgroundColor = [UIColor clearColor];
        _overlayWindow.userInteractionEnabled = YES;
        _overlayWindow.windowLevel = UIWindowLevelStatusBar;
    }
    return _overlayWindow;
}


- (UIView *)topBar {
    if(!_topBar) {
        _topBar = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, SCREEN_WIDTH, 20.0f)];
        [_overlayWindow addSubview:_topBar];
    }
    return _topBar;
}

- (UIImageView *)arrow
{
    if (!_arrawMark) {
        _arrawMark =[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 12, 6, 7, 7)];
        _arrawMark.image = [UIImage imageNamed:@"fanhui"];
        [self.topBar addSubview:_arrawMark];
    }
    return _arrawMark;
}

- (CBAutoScrollLabel *)scrollLabel {
    if (_scrollLabel == nil) {
        _scrollLabel = [[CBAutoScrollLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-20, 20)];
        _scrollLabel.textColor = [UIColor colorWithRed:191.0/255.0 green:191.0/255.0 blue:191.0/255.0 alpha:1.0];
        _scrollLabel.backgroundColor = [UIColor clearColor];
        _scrollLabel.textAlignment = NSTextAlignmentLeft;
        _scrollLabel.font = [UIFont boldSystemFontOfSize:14.0];
        _scrollLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    
    _scrollLabel.labelSpacing = 30;
    _scrollLabel.pauseInterval = 1.7;
    _scrollLabel.scrollSpeed = 30;
    _scrollLabel.fadeLength = 12.f;
    _scrollLabel.scrollDirection = CBAutoScrollDirectionLeft;
    [_scrollLabel observeApplicationNotifications];
    _scrollLabel.font = [UIFont systemFontOfSize:13.0f];
    if(!_scrollLabel.superview)
        [self.topBar addSubview:_scrollLabel];
    
    return _scrollLabel;
}

@end
