//
//  DPRPrinterTableViewCell.h
//  DevilPrint
//
//  Created by Davis Gossage on 7/22/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPRPrinter.h"

@interface DPRPrinterTableViewCell : UITableViewCell

- (void)setPrinter:(DPRPrinter*)printer;
- (void)setDLabel:(NSString*)labelText;

@end
