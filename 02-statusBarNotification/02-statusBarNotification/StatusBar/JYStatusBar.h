//
//  JYStatusBar.h
//  02-statusBarNotification
//
//  Created by 乐校 on 16/4/14.
//  Copyright © 2016年 lexiao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^touchClick)();

@interface JYStatusBar : UIView
@property (nonatomic, copy) touchClick click;

+ (JYStatusBar *)sharedView;
- (void)dismiss;
- (void)showWithText:(NSString *)text barColor:(UIColor *)barColor textColor:(UIColor *)textColor;
@end
