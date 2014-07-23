//
//  DPRPrinterTableViewCell.m
//  DevilPrint
//
//  Created by Davis Gossage on 7/22/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import "DPRPrinterTableViewCell.h"

@interface DPRPrinterTableViewCell(){
    IBOutlet UILabel *name;
    IBOutlet UILabel *locationDescription;      /// a combination of campus and building
    IBOutlet UILabel *directions;
    IBOutlet UIImageView *printerStatusImageView;
    IBOutlet UILabel *distanceLabel;
}

@end

@implementation DPRPrinterTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPrinter:(DPRPrinter *)printer{
    name.text = printer ? printer.name : @"";
    locationDescription.text = printer.site ? [NSString stringWithFormat:@"%@ Campus - %@", printer.site.campus, printer.site.building] : @"";
    directions.text = printer.site ? printer.site.directions : @"";
    printerStatusImageView.image = printer.status.image;
}

- (void)setDLabel:(NSString *)labelText{
    distanceLabel.text = labelText;
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
