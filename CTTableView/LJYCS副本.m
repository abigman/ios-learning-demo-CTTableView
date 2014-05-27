//
//  LJYCS.m
//  CTTableView
//
//  Created by Daniel Liu on 14-5-27.
//  Copyright (c) 2014年 wmss. All rights reserved.
//

#import "LJYCS.h"
#import <CoreText/CoreText.h>

// 缓存池
static NSMutableDictionary* cacheDict;
// 最小缓存的文字长度
int miniCacheLength = 30;

NSMutableDictionary* getD() {
    if (cacheDict == nil) {
        cacheDict = [NSMutableDictionary dictionary];
    }
    return cacheDict;
}

LJYCS* getFromCache(NSString* content) {
    if ([content length]  < miniCacheLength) {
        return nil;
    }
    
    NSMutableDictionary* d = getD();
    LJYCS* obj = [d objectForKey:content];
    return obj;
}
void cacheIt(LJYCS* obj) {
    if ([obj.content length] < miniCacheLength) {
        return;
    }
    
    [getD() setObject:obj forKey:obj.content];
}








@interface LJYCS ()
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;

@end

@implementation LJYCS

- (id)initWithMaxRect:(CGRect)rect withContent:(NSString *)content
{
    // 从缓存中获取
    id o = getFromCache(content);
    if (o) {
        //        NSLog(@"%@", o);
        return o;
    }
    
    
    
    
    if (self = [super init]) {
        self.content = [[NSAttributedString alloc] initWithString:content];
        self.width = rect.size.width;
    }
    // 加入缓存中
    cacheIt(self);
    
    
    return self;
}

- (CGRect)rect
{
    if (_rect.size.width != 0) {
        return _rect;
    }
    
    
    if (!_height) {
        
        CGRect rect = [self.content boundingRectWithSize:CGSizeMake(self.width, 100000)
                                                 options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                                 context:nil];
        _width = rect.size.width;
        _height = rect.size.height;
        if (_height < 20) {
            _height = 20;
        }
    }
    return CGRectMake(0, 0, _width, _height);
}


#pragma mark - 分成多个图片来绘制

- (void)drawLines:(NSArray*)lines toView:(UIView*)view
{
    
    // 获取lines 的矩形
    
    
    
    UIGraphicsBeginImageContextWithOptions(self.rect.size, NO, 0.0);
    
    // Retrieve the current context
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    /// toggle coordinate between left-up and left-down
    CGContextTranslateCTM(context, 0, self.rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    
    
    // Retrieve the drawn image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the image context
    UIGraphicsEndImageContext();
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [view addSubview:[[UIImageView alloc] initWithImage:image]];
    });
}
- (void)drawContentToView:(UIView *)view
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.content);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, self.rect);
        //use the column path
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        NSArray* lines = (NSArray*)CTFrameGetLines(frame);
        
        NSMutableArray* lines30 = [NSMutableArray array];
        for (int i=0; i < [lines count]; i++) {
            id line = [lines objectAtIndex:i];
            [lines30 addObject:line];
            if (i %30 == 0) {
                [self drawLines:lines30 toView:view];
                lines30 = [NSMutableArray array];
            }
        }
    });
}

@end
