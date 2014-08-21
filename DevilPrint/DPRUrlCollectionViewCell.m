//
//  DPRUrlCollectionViewCell.m
//  DevilPrint
//
//  Created by Davis Gossage on 8/16/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import "DPRUrlCollectionViewCell.h"
#import "AFNetworking.h"

@interface DPRUrlCollectionViewCell(){
    IBOutlet UIWebView *fileWebView;
    IBOutlet UIButton *printButton;
    IBOutlet UIActivityIndicatorView *printStatusIndicator;
}

@property NSURL *urlToPrint;

@end

@implementation DPRUrlCollectionViewCell

@synthesize urlToPrint;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)restoreButtonLabel{
    
}

- (void)flashSuccess{
    
}

- (IBAction)printButtonTapped:(id)sender{
    urlToPrint = [NSURL URLWithString:[UIPasteboard generalPasteboard].string];
    if([self.delegate respondsToSelector:@selector(userWantsToPrintUrl:sender:)]) {
        [self.delegate userWantsToPrintUrl:urlToPrint sender:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
