//
//  DPRFileCollectionViewCell.h
//  DevilPrint
//
//  Created by Davis Gossage on 7/31/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPRFileCollectionViewCellDelegate <NSObject>

- (void)userWantsToPrint:(NSURL*)urlToPrint sender:(id)sender;

@end

@interface DPRFileCollectionViewCell : UICollectionViewCell<UIWebViewDelegate>

@property (nonatomic,weak) id<DPRFileCollectionViewCellDelegate> delegate;

- (void)showFile:(NSString*)fileString;

- (IBAction)printButtonTapped:(id)sender;

- (void)restoreButtonLabel;

- (void)flashSuccess;

- (void)printingDidStart;
@end
