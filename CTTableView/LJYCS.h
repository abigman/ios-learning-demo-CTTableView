//
//  LJYCS.h
//  CTTableView
//
//  Created by Daniel Liu on 14-5-27.
//  Copyright (c) 2014年 wmss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LJYGCDTableViewCell.h"

@interface LJYCS : NSObject
@property (nonatomic, strong) NSAttributedString *content;
@property (assign, nonatomic) CGRect rect;

- (id)initWithMaxRect:(CGRect)rect withContent:(NSString*)content;
- (void)drawContentToView:(LJYGCDTableViewCell*)view atRow:(NSInteger)row;
@end
