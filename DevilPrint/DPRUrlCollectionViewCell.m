//
//  DPRUrlCollectionViewCell.m
//  DevilPrint
//
//  Created by Davis Gossage on 8/16/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import "DPRUrlCollectionViewCell.h"
#import "AFNetworking.h"
#import <MessageUI/MessageUI.h>

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
    printStatusIndicator.hidden = true;
    [printButton setTitle:@"Print URL" forState:UIControlStateNormal];
}

- (void)flashSuccess{
    printStatusIndicator.hidden = true;
    [printButton setTitle:@"Success!" forState:UIControlStateNormal];
    [self performSelector:@selector(restoreButtonLabel) withObject:nil afterDelay:3.0];
}

- (IBAction)contactUs:(id)sender{
    //i'm so lazy
    //in the future use the mfmailcontroller
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:devilprintapp@gmail.com"]];
}

- (IBAction)contribute:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/goose2460/DevilPrint"]];
}

- (IBAction)printButtonTapped:(id)sender{
    urlToPrint = [NSURL URLWithString:[UIPasteboard generalPasteboard].string];
    if([self.delegate respondsToSelector:@selector(userWantsToPrintUrl:sender:)]) {
        printStatusIndicator.hidden = false;
        [printButton setTitle:@"" forState:UIControlStateNormal];
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
