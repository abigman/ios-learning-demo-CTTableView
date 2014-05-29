//
//  LJYViewController.m
//  CTTableView
//
//  Created by Daniel Liu on 14-5-26.
//  Copyright (c) 2014年 wmss. All rights reserved.
//

#import "LJYViewController.h"
#import "LJYTableViewCell.h"
#import <CoreText/CoreText.h>


@interface LJYViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *contentArr;
@property (strong, nonatomic) NSMutableArray *attrContentArr;
@property (strong, nonatomic) NSDate *time1;

@end

@implementation LJYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.tableView registerClass:[LJYTableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    self.contentArr = [NSMutableArray arrayWithArray:@[
                                                       @"gggggggg1我很多字..等等等等等等等等等等等等等等等等.!!!attributestring123456789",
                                                       @"jjj多2我很多字...!!!等等等等等等等等等等等等等等等等",
                                                       @"3我18959264502 www.baidu.com 18959264502..!!!attributestring123456789是12345678a阿啊阿qq啊阿啊啊威武威武啊1111111111111111ooabcdefghijklmnopqrstuvwxyzpppppppppppppppppppppppIII你好",
                                                       @"4我很多字...!!!",
                                                       @"5我很多8-)8-)8-)8-)字...!!!",
                                                       @"6我很多字...!!!",
                                                       @"6我很多字...!!!我很多字...!!!我很多字...!!!我很多字8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)www.baidu.com www.baidu.com 8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)8-)..18959264502 18959264502.!!!我很多字...!!!我很多我很多字...!!!我很多字...!!!我很  多字...!!!我很多字...!!!我很多字...!!!我很多字...!!!我很多字...!!!我很多字...!!!我很多字...!!!我很多字...!!!我很多字...!!!我很多字...!!!字...!!!我很多字...!!!我很多字...!!!我很多字...!!!",
                                                       
                                                       ]];
    
    self.time1 = [NSDate date];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init property if not set
- (NSMutableArray *)contentArr
{
    if (!_contentArr) {
        _contentArr = [NSMutableArray array];
    }
    return _contentArr;
}
- (NSMutableArray *)attrContentArr
{
    if (!_attrContentArr) {
        _attrContentArr = [NSMutableArray array];
    }
    return _attrContentArr;
}



#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contentArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDate *time1 = [NSDate date];
        NSLog(@"%f require cell", [time1 timeIntervalSinceDate:self.time1]);
    });
    
    static NSString *cellIdentifier = @"Cell";
    
    LJYTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if ([self.contentArr count] >= indexPath.row) {
        CGRect rect = CGRectInset(self.view.bounds, 50, 50);
//        NSLog(@"%@ %@", NSStringFromCGRect(self.view.bounds), NSStringFromCGRect(rect));
        NSString* s = [self.contentArr objectAtIndex:indexPath.row];
//        s = [s substringWithRange:NSMakeRange(0, [s length]>3000? 3000:[s length])];
        
        [cell setRect:rect andContent:s];
        cell.bubble = @"qipao";
        cell.preLoad = YES;
    }

    return cell;
}


#pragma mark - UITableView Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.contentArr count] >= indexPath.row) {
        CGRect rect = CGRectInset(self.view.bounds, 50, 50);
        
        NSString* s = [self.contentArr objectAtIndex:indexPath.row];
//        s = [s substringWithRange:NSMakeRange(0, [s length]>3000? 3000:[s length])];
        LJYTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        [cell setRect:rect andContent:s];
        
        return cell.rect.size.height + 120;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end
