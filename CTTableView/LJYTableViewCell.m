//
//  LJYTableViewCell.m
//  CTTableView
//
//  Created by Daniel Liu on 14-5-28.
//  Copyright (c) 2014年 wmss. All rights reserved.
//

#import "LJYTableViewCell.h"
#import <CoreText/CoreText.h>


@interface LJYCS : NSObject

@property (assign, nonatomic) CGRect rect;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (strong, nonatomic) NSAttributedString *contentString;
@property (assign, nonatomic) CTFrameRef ctFrame;


- (instancetype)initWithRect:(CGRect)rect withContent:(NSString*)content;
@end
@implementation LJYCS

- (instancetype)initWithRect:(CGRect)rect withContent:(NSString *)content
{
    if (self = [super init]) {
        self.width = rect.size.width;
        
        
        
        self.contentString = [[NSAttributedString alloc] initWithString:content];
    }
    return self;
}

- (CGRect)rect
{
    if (_rect.size.width != 0) {
        return _rect;
    }
    
    if (!_height) {
        
        CGRect rect = [self.contentString boundingRectWithSize:CGSizeMake(self.width, 100000)
                                                 options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                                 context:nil];
        _width = rect.size.width;
        _height = rect.size.height;
        if (_height < 20) {
            _height = 20;
        }
        _rect = CGRectMake(0, 0, _width, _height);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.contentString);
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathAddRect(path, NULL, self.rect);
            self.ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        });
    }
    return _rect;
}

- (UIImage*)getContentImage
{
    UIImage* image;
    @autoreleasepool {
        /**
         *  离屏绘制界面
         */
        UIGraphicsBeginImageContextWithOptions(self.rect.size, NO, 0.0);
        
        // Retrieve the current context
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, self.rect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        
        CTFrameDraw((CTFrameRef)self.ctFrame, context);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

@end



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

void cacheContent(NSString* content, CGRect rect) {
    LJYCS* obj = [getD() objectForKey:content];
    if (!obj) {
        obj = [[LJYCS alloc] initWithRect:rect withContent:content];
    }
    [getD() setObject:obj forKey:content];
}

LJYCS* getFromCache(NSString* content) {
   
    NSMutableDictionary* d = getD();
    LJYCS* obj = [d objectForKey:content];
    return obj;
}









@interface LJYTableViewCell ()
@property (strong, nonatomic) NSString *content;
@property (weak, nonatomic) UIImageView *bubbleView;
@property (weak, nonatomic) UIImageView *textContentView;
@end





@implementation LJYTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - 设置cell 允许的宽度 以及cell 的文字内容
- (void)setRect:(CGRect)rect andContent:(NSString *)content
{
    // 扣除 为头像之类的东西保留位置
    rect = CGRectInset(rect, 10, 0);
    
    cacheContent(content, rect);
    self.content = content;
}

#pragma mark - 获取计算后cell 的矩形，主要时为了获取高度
/**
 *  计算cell占用的矩形大小
 *
 *  @return
 */
-(CGRect)rect
{
    LJYCS* cs = getFromCache(self.content);
    // 其他空间，如留白，头像占用位置之类的
    _rect = CGRectInset(cs.rect, -10, -10);
    return _rect;
}

#pragma mark - 设置气泡
/**
 *  设置气泡
 *
 *  @param bubble 气泡名称
 */
- (void)setBubble:(NSString *)bubble
{
    if ([_bubble isEqualToString:bubble]) {
        return;
    }
    if (self.bubbleView) {
        [self.bubbleView removeFromSuperview];
    }
    
    _bubble = bubble;

    UIImage *temp = [UIImage imageNamed:bubble];
    UIImage* i1 = [temp stretchableImageWithLeftCapWidth:temp.size.width/2 topCapHeight:temp.size.height/2];
    UIImageView* iv = [[UIImageView alloc] initWithImage:i1];
    iv.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:iv];
    self.bubbleView = iv;
}

#pragma mark - 将文字转换为图像
/**
 *  将文字绘制成图像
 *
 *  @return 文字图像
 */
- (UIImage*)getContentImage
{
    return [getFromCache(self.content) getContentImage];
}

#pragma mark - 将图片添加到气泡上
/**
 *  将图片绘制到气泡上, 并且改变气泡大小
 *
 *  @param image 要绘制的图片
 */
-(void)addTextContentViewToBubble:(UIImage*)image
{
    CGSize size = CGSizeMake(image.size.width, image.size.height);
    CGFloat gap = 10;
    UIImageView *textContentView = [[UIImageView alloc] initWithImage:image];
    [textContentView setFrame:CGRectMake(gap, gap, size.width, size.height)];
    [self.bubbleView addSubview:textContentView];
    self.textContentView = textContentView;
    
    
    [self.bubbleView setFrame:CGRectMake(30, 30, size.width + 2*gap , size.height + 2* gap)];
}

#pragma mark - 预载模式，也就是多线程啦啦啦
/**
 *  设置是否预载， （也即，异步加载）
 *  注意，不支持设定yes 后，又设定no
 *
 *  @param preLoad 是否预载
 */
- (void)setPreLoad:(BOOL)preLoad
{

    if (preLoad) {
        // 💔 💙 💚 💛 💜 💡 💢 💣
        NSAssert(self.content != nil, @"please call - (void)setRect:(CGRect)rect andContent:(NSString *)content; beforse this  💔 💔 💔 💔 💔 💔");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage* image = [self getContentImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                // 由于时异步的，防止滚动过头了
                if (!self.textContentView) {
                    [self addTextContentViewToBubble:image];
                }
            });
        });
    }
    _preLoad = preLoad;
}


- (void)prepareForReuse
{
    [self.textContentView removeFromSuperview];
}

@end
