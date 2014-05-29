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
@property (strong, nonatomic) NSMutableAttributedString *contentString;
@property (assign, nonatomic) CTFrameRef ctFrame;
@property (strong, nonatomic) NSMutableArray *clickAbleAttributeStrings;


- (instancetype)initWithRect:(CGRect)rect withContent:(NSString*)content;
@end
@implementation LJYCS

- (instancetype)initWithRect:(CGRect)rect withContent:(NSString *)content
{
    if (self = [super init]) {
        self.width = rect.size.width;
        
        // 设置要绘制的颜色
        NSMutableAttributedString* contentString = [[NSMutableAttributedString alloc] initWithString:@""];
        
        NSError *error = NULL;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:&error];
        if (error != NULL) {
            NSAssert(NO, @"detect link and phoneNumber error 💢 💢 💢 💢 💢 💢 💢");
        }
        NSArray *matchs = [detector matchesInString:content options:0 range:NSMakeRange(0, [content length])];
        NSUInteger locationIndex = 0;
        UIFont *font = [UIFont fontWithName:@"Palatino-Roman" size:20.0];
        for (NSTextCheckingResult *match in matchs) {
            NSRange matchRange = [match range];
            if (matchRange.location != locationIndex) {
                NSRange range;
                range.location = locationIndex;
                range.length = matchRange.location - locationIndex;
                NSAttributedString* as = [[NSAttributedString alloc] initWithString:[content substringWithRange:range] attributes:@{
                                                                                                                                    NSFontAttributeName: font
                                                                                                                                    }];
//                NSLog(@"!= %@", [content substringWithRange:range]);
                [contentString appendAttributedString:as];
            }
            
            locationIndex = matchRange.location + matchRange.length;
            NSString* c =  [NSString stringWithFormat:@"%@", [content substringWithRange:matchRange]];  // 识别效果也不怎地啊
            NSAttributedString* as = [[NSAttributedString alloc] initWithString:c attributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
                                                                                                                                     NSForegroundColorAttributeName:[UIColor blueColor],
                                                                                                                                     NSFontAttributeName: font}];
            // 加入识别字符串
            [self.clickAbleAttributeStrings addObject:[NSValue valueWithRange:matchRange]];
//            NSLog(@"match %@", c);

//            if ([match resultType] == NSTextCheckingTypeLink) {
//            } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
//            }
            
            [contentString appendAttributedString:as];
        }
        
        if (locationIndex < [content length])
        {
            
            NSString* s = [content substringFromIndex:locationIndex];
//            NSLog(@"out %@", s);
            NSAttributedString* as = [[NSAttributedString alloc] initWithString:s attributes:@{NSFontAttributeName: font}];
            [contentString appendAttributedString:as];
        }
        
//        NSLog(@"%@ 💔 💔 💔 💔 💔 💔", contentString);     // 💔 💙 💚 💛 💜 💡 💢 💣
        
        self.contentString = contentString;
//        self.contentString = [[NSAttributedString alloc] initWithString:content];
    }
    return self;
}

- (NSMutableAttributedString*)fixLastLineMissBugWhenDrawWithCoreText:(NSMutableAttributedString*)content
{
    //段落
    //line break
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping; //换行模式
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    //行间距
    CTParagraphStyleSetting LineSpacing;
    CGFloat spacing = 4.0;  //指定间距
    LineSpacing.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    LineSpacing.value = &spacing;
    LineSpacing.valueSize = sizeof(CGFloat);
    
    CTParagraphStyleSetting settings[] = {lineBreakMode,LineSpacing};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 2);   //第二个参数为settings的长度
    [content addAttribute:(NSString *)kCTParagraphStyleAttributeName
                             value:(__bridge id)paragraphStyle
                             range:NSMakeRange(0, content.length)];
    return content;
    
}
- (NSMutableArray *)clickAbleAttributeStrings
{
    if (!_clickAbleAttributeStrings) {
        _clickAbleAttributeStrings = [NSMutableArray array];
    }
    return _clickAbleAttributeStrings;
}
- (CGRect)rect
{

//    if (_rect.size.width != 0) {
//        return _rect;
//    }
    
    if (!_height) {
        
        self.contentString = [self fixLastLineMissBugWhenDrawWithCoreText:self.contentString];
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.contentString);
//        NSLog(@"%@ 💙💙💙💙💙💙", self.contentString);     // 💔 💙 💚 💛 💜 💡 💢 💣
        
        // 计算绘制区域，包括高度之类的
        CFRange fitRange;
        CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [self.contentString length]), NULL, CGSizeMake(_width, 10000), &fitRange);
        if (fitRange.length != [self.contentString length]) {
            NSLog(@"too long string to render 💔 💔 💔 💔 💔 💔");     // 💔 💙 💚 💛 💜 💡 💢 💣
        }
        _width = size.width;
        _height = size.height;
        _rect = CGRectMake(0, 0, _width, _height);
        NSLog(@"calculate size: %@", NSStringFromCGSize(size));
 
        
        // 创建ctframe， 注意必须先计算_rect
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, _rect);
        self.ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        

    }

    return _rect;
}

- (UIImage*)getContentImage
{
    NSLog(@"draw image");
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
    
//    NSLog(@"💡 💡 💡 rectSize:%@ size:%@ draw:  %@", NSStringFromCGSize(self.rect.size), NSStringFromCGSize(image.size), self.contentString);
    return image;
}

- (void)dealloc
{
    self.clickAbleAttributeStrings = nil;
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
        /**
         *  添加点击识别
         */
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBubbleView:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}


#pragma mark - 点击识别
-(void)tapOnBubbleView:(UITapGestureRecognizer*)tapGest
{
    if (!self.textContentView) {
        return;
    }
    
    LJYCS* cs = getFromCache(self.content);
    CTFrameRef frame= cs.ctFrame;
    CGPoint tapPoint = [tapGest locationInView:self.textContentView];
    //获取触摸点击当前view的坐标位置
    NSLog(@"touch:%@",NSStringFromCGPoint(tapPoint));
    //获取每一行
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint origins[CFArrayGetCount(lines)];
    //获取每行的原点坐标
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    CTLineRef line = NULL;
    CGPoint lineOrigin = CGPointZero;
    for (int i= 0; i < CFArrayGetCount(lines); i++)
    {
        CGPoint origin = origins[i];
        CGPathRef path = CTFrameGetPath(frame);
        //获取整个CTFrame的大小
        CGRect rect = CGPathGetBoundingBox(path);
        NSLog(@"origin:%@",NSStringFromCGPoint(origin));
        NSLog(@"rect:%@",NSStringFromCGRect(rect));
        //坐标转换，把每行的原点坐标转换为uiview的坐标体系
        CGFloat y = rect.origin.y + rect.size.height - origin.y;
        NSLog(@"y:%f",y);
        //判断点击的位置处于那一行范围内
        if ((tapPoint.y <= y) && (tapPoint.x >= origin.x))
        {
            line = CFArrayGetValueAtIndex(lines, i);
            lineOrigin = origin;
            break;
        }
    }
    
    tapPoint.x -= lineOrigin.x;
    //获取点击位置所处的字符位置，就是相当于点击了第几个字符
    CFIndex index = CTLineGetStringIndexForPosition(line, tapPoint);
    NSLog(@"index:%ld",index);
    //判断点击的字符是否在需要处理点击事件的字符串范围内，这里是hard code了需要触发事件的字符串范围
    for (NSValue* v in cs.clickAbleAttributeStrings) {
        NSRange range = [v rangeValue];
        if (index < range.location) {
            return;
        }
        if (index >= range.location && index <= range.location + range.length) {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"click event" message:[self.content substringWithRange:range] delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
            [alert show];
        }
    }

    
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
    _rect = CGRectInset(cs.rect, -30, -30);
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
//    NSLog(@"height is : %f", textContentView.bounds.size.height);
//    [textContentView setBackgroundColor:[UIColor redColor]];
    [self.bubbleView addSubview:textContentView];
    self.textContentView = textContentView;
    
    self.bubbleView.clipsToBounds = NO;
    [self.bubbleView setBackgroundColor:[UIColor greenColor]];
    [self.bubbleView setFrame:CGRectMake(30, 30, size.width + 2*gap , size.height + 2* gap)];
//    [self.bubbleView setFrame:CGRectMake(30, 30, 300, 200)];
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
