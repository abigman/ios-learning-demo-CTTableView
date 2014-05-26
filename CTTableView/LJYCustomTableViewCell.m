//
//  LJYCustomTableViewCell.m
//  CTTableView
//
//  Created by Daniel Liu on 14-5-26.
//  Copyright (c) 2014年 wmss. All rights reserved.
//

#import "LJYCustomTableViewCell.h"

@implementation LJYCustomTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
