//
//  DPRFileCollectionViewCell.h
//  DevilPrint
//
//  Created by Davis Gossage on 7/31/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPRFileCollectionViewCellDelegate <NSObject>

- (void)userWantsToPrint:(NSURL*)urlToPrint;

@end

@interface DPRFileCollectionViewCell : UICollectionViewCell<UIWebViewDelegate>

@property (nonatomic,weak) id<DPRFileCollectionViewCellDelegate> delegate;

- (void)showFile:(NSString*)fileString;

@end
