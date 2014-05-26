//
//  LJYCustomAttributeString.h
//  CTTableView
//
//  Created by Daniel Liu on 14-5-26.
//  Copyright (c) 2014年 wmss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJYCustomAttributeString : NSObject

@property (assign, nonatomic) CGFloat height;
@property (strong, nonatomic) NSAttributedString *attrString;
@property (strong, nonatomic, readonly) NSString *content;


-(instancetype)initWith:(NSString*)content withWidth:(CGFloat)width;

@end
