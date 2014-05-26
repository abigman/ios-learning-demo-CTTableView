//
//  LJYCustomAttributeString.m
//  CTTableView
//
//  Created by Daniel Liu on 14-5-26.
//  Copyright (c) 2014年 wmss. All rights reserved.
//

#import "LJYCustomAttributeString.h"

@interface LJYCustomAttributeString ()

@property (assign, nonatomic) CGFloat width;
@property (strong, nonatomic, readwrite) NSString *content;

@end

@implementation LJYCustomAttributeString

- (instancetype)initWith:(NSString *)content withWidth:(CGFloat)width
{
    if (self = [super init]) {
        self.content = content;
        self.attrString = [self parseContent:content];
        self.width = width;
    }
    return self;
}

- (CGFloat)height
{
    if (!_width|| _width == 0) {
        // 💔 💙 💚 💛 💜 💡 💢 💣
        NSAssert(NO, @"you should assign width before read height and width shouldn't be 0 💔 💔 💔 💔 💔 💔");
    }
    
    if (!_height) {
        CGRect rect = [self.attrString boundingRectWithSize:CGSizeMake(_width, 100000) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        _height = rect.size.height;
    }
    return _height;
}

- (NSAttributedString*)parseContent:(NSString*)content
{
    NSMutableAttributedString* attrS;
    
    attrS = [[NSMutableAttributedString alloc] initWithString:content attributes:nil];
    
    return attrS;
}

@end
