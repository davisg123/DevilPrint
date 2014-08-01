//
//  DPRFileCollectionViewCell.h
//  DevilPrint
//
//  Created by Davis Gossage on 7/31/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPRFileCollectionViewCell : UICollectionViewCell<UIWebViewDelegate>

- (void)showFile:(NSString*)fileString;

@end
