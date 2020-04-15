//
//  MenuButton.h
//  CZHProject
//
//  Created by JiuQianJi on 2019/7/31.
//  Copyright © 2019 JiuQianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CHButtonImagePosition) {
    CHButtonImagePositionTop = 0,
    CHButtonImagePositionLeft,
    CHButtonImagePositionBottom,
    CHButtonImagePositionRight,
};

@protocol MenuButtonDataSource <NSObject>
@required
/// 菜单显示的标题，填充的数据类型必须实现该协议
@property (nonatomic, copy) NSString *itemTitle;

@end


@interface CHButton : UIButton
@property (nonatomic, assign) CHButtonImagePosition imagePosition;
@property (nonatomic, assign) IBInspectable CGFloat spaceTitleAndImage;
@property (nonatomic, strong) UIColor *borderColor;
/// 镂空按钮 边框和字体颜色一样 默认圆角为高度的一半
@property (nonatomic, assign) UIColor *ghostColor;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;

#pragma mark 弹出菜单相关属性
/// 如果列表只是string 请传入此数组
@property (nonatomic, strong) NSArray<NSString *> *titleArray;
/// 如果是请求获取的数据模型列表，请传入此数据源（数组模型请实现MenuButtonDataSource协议，模型添加itemTitle字段用来在菜单中显示）
@property (nonatomic, strong) NSArray<id<MenuButtonDataSource>> *dataArray;
@property(nonatomic,assign) CGFloat menuWidth;
@property(nonatomic,assign) CGFloat maxHeight;
@property(nonatomic,assign) CGFloat rowHeight;
@property(nonatomic,strong) UIFont *titleFont;
@property(nonatomic,strong) UIColor *titleColor;

/// 是否显示选中 default NO
@property(nonatomic,assign) BOOL showSelected;

// 标题对齐方式
@property(nonatomic,assign) NSTextAlignment textAlignment;
/// 当弹出菜单的width != 按钮的withd时，可设置菜单与按钮左对齐还是右对齐 // 设置UIViewContentModeRight  UIViewContentModeLeft 有效
@property (nonatomic,assign) UIViewContentMode contentAlignment;

@property(nonatomic,copy) void(^clickBlock)(NSInteger index,id data);
-(void)showMenu;
@end

NS_ASSUME_NONNULL_END
