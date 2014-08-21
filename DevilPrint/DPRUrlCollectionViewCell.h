//
//  DPRUrlCollectionViewCell.h
//  DevilPrint
//
//  Created by Davis Gossage on 8/16/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPRUrlCollectionViewCellDelegate <NSObject>

- (void)userWantsToPrintUrl:(NSURL*)urlToPrint sender:(id)sender;

@end

@interface DPRUrlCollectionViewCell : UICollectionViewCell

@property (nonatomic,weak) id<DPRUrlCollectionViewCellDelegate> delegate;

- (IBAction)printButtonTapped:(id)sender;

- (void)restoreButtonLabel;

- (void)flashSuccess;

@end
