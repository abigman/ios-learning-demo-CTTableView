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
int miniCacheLength = 0;

NSMutableDictionary* getD() {
    if (cacheDict == nil) {
        cacheDict = [NSMutableDictionary dictionary];
    }
    return cacheDict;
}

LJYCS* getFromCache(NSString* content) {
//    if ([content length]  < miniCacheLength) {
//        return nil;
//    }
    
    NSMutableDictionary* d = getD();
    LJYCS* obj = [d objectForKey:content];
    return obj;
}
void cacheIt(LJYCS* obj) {
//    if ([obj.content length] < miniCacheLength) {
//        return;
//    }
    
    [getD() setObject:obj forKey:obj.content.string];
}








@interface LJYCS ()
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CTFrameRef ctFrame;

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
        _rect = CGRectMake(0, 0, _width, _height);
        
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.content);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, self.rect);
        self.ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        
    }
    return _rect;
}


#pragma mark - 
- (void)drawContentToView:(LJYGCDTableViewCell *)view atRow:(NSInteger)row
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        

            @autoreleasepool {
                UIImage *image;
                UIGraphicsBeginImageContextWithOptions(self.rect.size, NO, 0.0);
                
                // Retrieve the current context
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                CGContextTranslateCTM(context, 0, self.rect.size.height);
                CGContextScaleCTM(context, 1.0, -1.0);
                CTFrameDraw((CTFrameRef)self.ctFrame, context);
                
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (view.rowIndex == row) {
                        [view.contentView addSubview:[[UIImageView alloc] initWithImage:image]];
                    }
                });
            }
            


        
        

    });
}

@end
