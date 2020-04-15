//
//  MenuButton.m
//  CZHProject
//
//  Created by JiuQianJi on 2019/7/31.
//  Copyright © 2019 JiuQianJi. All rights reserved.
//

#import "CHButton.h"
#define IMG(img) [UIImage imageNamed:img]
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface CHButton ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic, strong) UIView *maskView;
@property(nonatomic,strong) NSIndexPath *selectedIndexPath;

@end
CG_INLINE CGFloat
UIEdgeHorizontalValue(UIEdgeInsets inset){
    return inset.left + inset.right;
}
CG_INLINE CGFloat
UIEdgeVerticalValue(UIEdgeInsets inset){
    return inset.top + inset.bottom;
}
@implementation CHButton


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitialize];
        // iOS7以后 sizeToFit会默认带有上下边距
        self.contentEdgeInsets = UIEdgeInsetsMake(CGFLOAT_MIN, 0, 0, CGFLOAT_MIN);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self didInitialize];
    }
    return self;
}
-(void)didInitialize{
    // 去掉按钮高亮时的灰色状态
    self.adjustsImageWhenHighlighted = NO;
    self.adjustsImageWhenDisabled = NO;
    // 默认图片在左边
    self.imagePosition = CHButtonImagePositionLeft;
    // 默认图片和文件的间距为3
    self.spaceTitleAndImage = 3;
}

- (CGSize)sizeThatFits:(CGSize)size{
    // 调用sizeToFit时不限制宽高
    if (CGSizeEqualToSize(self.bounds.size, size)) {
        size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    }
    BOOL showImageView = !!self.currentImage;
    BOOL showTitleLabel = !!self.currentTitle || self.currentAttributedTitle;
    CGSize imageTotalSize = CGSizeZero;
    CGSize titleTotalSize = CGSizeZero;
    // 如果文字和图片没有同时存在 则间距为0
    CGFloat spaceTitleAndImage = showImageView && showTitleLabel ? self.spaceTitleAndImage : 0;
    CGSize resultSize = CGSizeZero;
    // 去掉边距后的大小
    CGSize contentLimitSize = CGSizeMake(size.width - UIEdgeHorizontalValue(self.contentEdgeInsets), size.height - UIEdgeVerticalValue(self.contentEdgeInsets));
    switch (self.imagePosition) {
            /// 上下排版
        case CHButtonImagePositionTop:
        case CHButtonImagePositionBottom:{
            if (showImageView) {
                CGFloat imageMaxWidth = contentLimitSize.width - UIEdgeHorizontalValue(self.imageEdgeInsets);
                CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(imageMaxWidth, CGFLOAT_MAX)];
                imageSize.width = fmin(imageSize.width, imageMaxWidth);
                imageTotalSize = CGSizeMake(imageSize.width + UIEdgeHorizontalValue(self.imageEdgeInsets), imageSize.height + UIEdgeVerticalValue(self.imageEdgeInsets));
            }
            if (showTitleLabel) {
                CGSize titleMaxSize = CGSizeMake(contentLimitSize.width - UIEdgeHorizontalValue(self.titleEdgeInsets), contentLimitSize.height - UIEdgeHorizontalValue(self.titleEdgeInsets) - spaceTitleAndImage - imageTotalSize.height);
                CGSize titleSize = [self.titleLabel sizeThatFits:titleMaxSize];
                titleSize.height = fmin(titleSize.height, titleMaxSize.height);
                titleTotalSize = CGSizeMake(titleSize.width + UIEdgeHorizontalValue(self.titleEdgeInsets), titleSize.height + UIEdgeVerticalValue(self.titleEdgeInsets));
            }
            resultSize.width = UIEdgeHorizontalValue(self.contentEdgeInsets) + fmax(imageTotalSize.width, titleTotalSize.width);
            resultSize.height = UIEdgeVerticalValue(self.contentEdgeInsets) + imageTotalSize.height + spaceTitleAndImage + titleTotalSize.height;
        }
        break;
            /// 左右排版
        case CHButtonImagePositionLeft:
        case CHButtonImagePositionRight:{
            if (showImageView) {
                CGFloat imageMaxHeight = contentLimitSize.height - UIEdgeVerticalValue(self.imageEdgeInsets);
                CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(CGFLOAT_MAX, imageMaxHeight)];
                imageSize.height = fmin(imageSize.height, imageMaxHeight);
                imageTotalSize = CGSizeMake(imageSize.width + UIEdgeHorizontalValue(self.imageEdgeInsets), imageSize.height + UIEdgeVerticalValue(self.imageEdgeInsets));
            }
            if (showTitleLabel) {
                CGSize titleMaxSize = CGSizeMake(contentLimitSize.width - UIEdgeHorizontalValue(self.titleEdgeInsets) - spaceTitleAndImage - imageTotalSize.width, contentLimitSize.height - UIEdgeHorizontalValue(self.titleEdgeInsets));
                CGSize titleSize = [self.titleLabel sizeThatFits:titleMaxSize];
                titleSize.width = fmin(titleSize.width, titleMaxSize.width);
                titleTotalSize = CGSizeMake(titleSize.width + UIEdgeHorizontalValue(self.titleEdgeInsets), titleSize.height + UIEdgeVerticalValue(self.titleEdgeInsets));
            }
            resultSize.height = UIEdgeHorizontalValue(self.contentEdgeInsets) + fmax(imageTotalSize.height, titleTotalSize.height);
            resultSize.width = UIEdgeHorizontalValue(self.contentEdgeInsets) + imageTotalSize.width + spaceTitleAndImage + titleTotalSize.width;
        }
            
        default:
            break;
    }
    return resultSize;
}

-(CGSize)intrinsicContentSize{
    // 当设置约束后 根据内容自动计算出内容大小(为内置大小)。没有设置frame或者宽高的约束时 使用此大小
    return [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    BOOL showImageView = !!self.currentImage;
   BOOL showTitleLabel = !!self.currentTitle || self.currentAttributedTitle;
    CGSize imageLimitSize = CGSizeZero;
    CGSize titleLimitSize = CGSizeZero;
   CGSize imageTotalSize = CGSizeZero;
   CGSize titleTotalSize = CGSizeZero;
   // 如果文字和图片没有同时存在 则间距为0
   CGFloat spaceTitleAndImage = showImageView && showTitleLabel ? self.spaceTitleAndImage : 0;
   CGRect imageFrame = CGRectZero;
   CGRect titleFrame = CGRectZero;
   CGSize contentSize = CGSizeMake(CGRectGetWidth(self.bounds) - UIEdgeHorizontalValue(self.contentEdgeInsets), CGRectGetHeight(self.bounds) - UIEdgeVerticalValue(self.contentEdgeInsets));
    // 不管怎么布局。图片都要尽量完整展示，所以大小都是一样的
    if (showImageView) {
        imageLimitSize = CGSizeMake(contentSize.width - UIEdgeHorizontalValue(self.imageEdgeInsets), contentSize.height - UIEdgeVerticalValue(self.imageEdgeInsets));
        CGSize imageSize = [self.imageView sizeThatFits:imageLimitSize];
        imageSize = CGSizeMake(fmin(imageLimitSize.width, imageSize.width), fmin(imageLimitSize.height, imageSize.height));
        imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        imageTotalSize = CGSizeMake(imageSize.width + UIEdgeHorizontalValue(self.imageEdgeInsets), imageSize.height + UIEdgeVerticalValue(self.imageEdgeInsets));
    }
    if (self.imagePosition == CHButtonImagePositionTop || self.imagePosition == CHButtonImagePositionBottom) {
        if (showTitleLabel) {
            titleLimitSize = CGSizeMake(contentSize.width - UIEdgeHorizontalValue(self.titleEdgeInsets), contentSize.height - UIEdgeVerticalValue(self.titleEdgeInsets) - spaceTitleAndImage - imageTotalSize.height);
            CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
            titleSize = CGSizeMake(fmin(titleLimitSize.width, titleSize.width), fmin(titleLimitSize.height, titleSize.height));
            titleFrame = CGRectMake(0, 0, titleSize.width, titleSize.height);
            titleTotalSize = CGSizeMake(titleSize.width + UIEdgeHorizontalValue(self.titleEdgeInsets), titleSize.height + UIEdgeVerticalValue(self.titleEdgeInsets));
        }
        if (showImageView) {
            imageFrame.origin.x = self.contentEdgeInsets.left + self.imageEdgeInsets.left + (imageLimitSize.width - CGRectGetWidth(imageFrame))/2;
        }
        if (showTitleLabel) {
            titleFrame.origin.x = self.contentEdgeInsets.left + self.imageEdgeInsets.left + (titleLimitSize.width - CGRectGetWidth(titleFrame))/2;
        }
        if (self.imagePosition == CHButtonImagePositionTop) {
            CGFloat contentHeight = imageTotalSize.height + spaceTitleAndImage + titleTotalSize.height;
            CGFloat minY = (contentSize.height - contentHeight) / 2 + self.contentEdgeInsets.top;
            if (showImageView) {
                imageFrame.origin.y = minY + self.imageEdgeInsets.top;
            }
            if (showTitleLabel) {
                titleFrame.origin.y = minY + self.imageEdgeInsets.top + imageTotalSize.height + spaceTitleAndImage;
            }
        }else{
            CGFloat contentHeight = imageTotalSize.height + spaceTitleAndImage + titleTotalSize.height;
            CGFloat minY = (contentSize.height - contentHeight) / 2 + self.contentEdgeInsets.top;
            if (showTitleLabel) {
                titleFrame.origin.y = minY + self.titleEdgeInsets.top;
            }
            if (showImageView) {
                imageFrame.origin.y = minY + self.titleEdgeInsets.top + titleTotalSize.height + spaceTitleAndImage;
            }
        }
    }else if (self.imagePosition == CHButtonImagePositionLeft || self.imagePosition == CHButtonImagePositionRight){
        if (showTitleLabel) {
            titleLimitSize = CGSizeMake(contentSize.width - UIEdgeHorizontalValue(self.titleEdgeInsets) - spaceTitleAndImage - imageTotalSize.width, contentSize.height - UIEdgeVerticalValue(self.titleEdgeInsets));
           CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
           titleSize = CGSizeMake(fmin(titleLimitSize.width, titleSize.width), fmin(titleLimitSize.height, titleSize.height));
           titleFrame = CGRectMake(0, 0, titleSize.width, titleSize.height);
           titleTotalSize = CGSizeMake(titleSize.width + UIEdgeHorizontalValue(self.titleEdgeInsets), titleSize.height + UIEdgeVerticalValue(self.titleEdgeInsets));
       }
       if (showImageView) {
           imageFrame.origin.y = self.contentEdgeInsets.top + self.imageEdgeInsets.top + (imageLimitSize.height - CGRectGetHeight(imageFrame))/2;
       }
       if (showTitleLabel) {
           titleFrame.origin.y = self.contentEdgeInsets.top + self.imageEdgeInsets.top + (titleLimitSize.height - CGRectGetHeight(titleFrame))/2;
       }
        CGFloat contentWidth= imageTotalSize.width + spaceTitleAndImage + titleTotalSize.width;
        CGFloat minX = (contentSize.width - contentWidth) / 2 + self.contentEdgeInsets.left;

       if (self.imagePosition == CHButtonImagePositionLeft) {
           if (showImageView) {
               imageFrame.origin.x = minX + self.imageEdgeInsets.left;
           }
           if (showTitleLabel) {
               titleFrame.origin.x = minX + self.imageEdgeInsets.left + imageTotalSize.width + spaceTitleAndImage;
           }
       }else{
           if (showTitleLabel) {
               titleFrame.origin.x = minX + self.titleEdgeInsets.left;
           }
           if (showImageView) {
               imageFrame.origin.x = minX + self.titleEdgeInsets.left + titleTotalSize.width + spaceTitleAndImage;
           }
       }
    }
    self.titleLabel.frame = titleFrame;
    self.imageView.frame = imageFrame;
}


-(void)setSpaceTitleAndImage:(CGFloat)spaceTitleAndImage{
    _spaceTitleAndImage = spaceTitleAndImage;
    [self setNeedsLayout];
}

-(void)setImagePosition:(CHButtonImagePosition)imagePosition{
    _imagePosition = imagePosition;
    [self setNeedsLayout];
}

-(void)setBorderColor:(UIColor *)borderColor{
    _borderColor = borderColor;
    self.layer.borderWidth = 1;
    self.layer.borderColor = borderColor.CGColor;
}
-(void)setCornerRadius:(CGFloat)cornerRadius{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}
-(void)setGhostColor:(UIColor *)ghostColor{
    _ghostColor = ghostColor;
    self.borderColor = ghostColor;
    self.cornerRadius = self.bounds.size.height/2;
    [self setTitleColor:ghostColor forState:UIControlStateNormal];
}
#pragma mark 弹出菜单相关属性

-(UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        _maskView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaskView:)];
        tap.cancelsTouchesInView = NO;//不取消子视图的点击事件
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType{
    CHButton *btn = [super buttonWithType:buttonType];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [btn setImage:IMG(@"icon_s_jts_") forState:UIControlStateNormal];
    [btn setImage:IMG(@"icon_s_jt") forState:UIControlStateSelected];
    btn.imagePosition = CHButtonImagePositionRight;
    btn.spaceTitleAndImage = 5;
    return btn;
}
-(UITableView *)tableView{
    if (!_tableView) {
        // tableview设置阴影后滑动时cell会超出tableview，所以外面再包一层
        UIView *contentView = [[UIView alloc] init];
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
//        _tableView.separatorColor = UIColorMake(238, 238, 238);
        _tableView.bounces = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.layer.cornerRadius = 5;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"menucell"];
        contentView.layer.shadowColor = [UIColor blackColor].CGColor;
        contentView.layer.shadowOffset = CGSizeMake(0, 0);
        contentView.layer.shadowRadius = 5;
        contentView.layer.shadowOpacity = 0.2;
        _tableView.tableFooterView = [UIView new];
        [contentView addSubview:_tableView];
        [self.maskView addSubview:contentView];
        
    }
    return _tableView;
}

-(void)setDataArray:(NSArray<id<MenuButtonDataSource>> *)dataArray{
    _dataArray = dataArray;
    [self addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
}
-(void)setTitleArray:(NSArray<NSString *> *)titleArray{
    _titleArray = titleArray;
    [self addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
}
-(void)tapMaskView:(UITapGestureRecognizer *)gesture{
  CGPoint point =  [gesture locationInView:self.maskView];
    if(!CGRectContainsPoint(self.tableView.superview.frame, point)){
        [self hideMenu];
    }
}
-(BOOL)isTitleArray{
    return self.titleArray.count;
}
#pragma mark - UITableViewDataSource
#define AutoTitleValue(leftValue,rightValue) ([self isTitleArray] ? leftValue : rightValue)
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return AutoTitleValue(self.titleArray.count, self.dataArray.count);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menucell" forIndexPath:indexPath];
//    cell.imageView.image = IMG(@"1");
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text =  AutoTitleValue(self.titleArray[indexPath.row], self.dataArray[indexPath.row].itemTitle);
    cell.textLabel.textAlignment = self.textAlignment;
    cell.textLabel.font = self.titleFont ?: [UIFont systemFontOfSize:16];
    if ((self.selectedIndexPath == indexPath) && self.showSelected) {
        cell.textLabel.textColor = [UIColor redColor];
    }else{
        cell.textLabel.textColor = self.titleColor?:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.rowHeight ?: 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self setTitle:AutoTitleValue(self.titleArray[indexPath.row], self.dataArray[indexPath.row].itemTitle) forState:UIControlStateNormal];
    self.selectedIndexPath = indexPath;
    if (self.clickBlock) {
        self.clickBlock(indexPath.row,AutoTitleValue(self.titleArray[indexPath.row], self.dataArray[indexPath.row].itemTitle));
    }
    [self hideMenu];
    
}

-(void)showMenu{
    self.selected = YES;
    // 计算按钮在屏幕上的位置
    CGRect react = [self.superview convertRect:self.frame toView:self.maskView];
    // 菜单宽高
    CGFloat height = self.maxHeight ?: MIN(100, [self.tableView numberOfRowsInSection:0] * (self.rowHeight ?: 40));
    CGFloat width = self.menuWidth ?: react.size.width;
    if (!self.contentAlignment) {
        if (CGRectGetMinX(react)+width <= SCREEN_WIDTH) { 
            self.contentAlignment = UIViewContentModeLeft;
        }else{
            self.contentAlignment = UIViewContentModeRight;
        }
    }
    CGFloat x = self.contentAlignment == UIViewContentModeRight ? (CGRectGetMaxX(react) - width) : CGRectGetMinX(react);
     // 如果放在按钮下面菜单超出了屏幕，就放在按钮上面
    if ((CGRectGetMaxY(react)+height+2) <= SCREEN_HEIGHT) {
        self.tableView.superview.frame = CGRectMake(x, CGRectGetMaxY(react)+2, width, height);
    }else{
        self.tableView.superview.frame = CGRectMake(x, CGRectGetMinY(react) - height - 2, width, height);
    }
    self.tableView.frame = self.tableView.superview.bounds;
    [self.tableView reloadData];
    [UIApplication.sharedApplication.delegate.window addSubview:self.maskView];
}
-(void)hideMenu{
    self.selected = NO;
    [self.maskView removeFromSuperview];
}


-(void)tapAction{
    
    self.selected = !self.selected;
    if (self.selected) {
        [self showMenu];
    }else{
        [self hideMenu];
    }
}
@end
