//
//  LJYTableViewCell.h
//  CTTableView
//
//  Created by Daniel Liu on 14-5-28.
//  Copyright (c) 2014年 wmss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJYTableViewCell : UITableViewCell
@property (nonatomic, assign) NSInteger rowIndex;
@property (assign, nonatomic) CGRect rect;
@property (strong, nonatomic) NSString *bubble;
@property (assign, nonatomic) BOOL preLoad; // 这个要在 - (void)setRect:(CGRect)rect andContent:(NSString *)content; 方法后面调用

- (void)setRect:(CGRect)rect andContent:(NSString *)content;
@end
