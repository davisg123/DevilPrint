//
//  DPRFileCollectionViewCell.m
//  DevilPrint
//
//  Created by Davis Gossage on 7/31/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import "DPRFileCollectionViewCell.h"

@interface DPRFileCollectionViewCell(){
    IBOutlet UIWebView *fileWebView;
    IBOutlet UIButton *printButton;
}

@property NSURL *urlToPrint;

@end

@implementation DPRFileCollectionViewCell
@synthesize urlToPrint;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareForReuse{
    //go to an empty website so cells don't display other cell's files
    [fileWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

- (void)showFile:(NSString *)fileString{
    fileWebView.delegate = self;
    urlToPrint = [NSURL fileURLWithPath:fileString];
    NSURLRequest *req = [NSURLRequest requestWithURL:urlToPrint];
    [fileWebView loadRequest:req];
    [printButton setTitle:urlToPrint.lastPathComponent forState:UIControlStateNormal];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
    CGSize contentSize = theWebView.scrollView.contentSize;
    CGSize viewSize = fileWebView.bounds.size;
    
    float rw = viewSize.width / contentSize.width;
    
    theWebView.scrollView.minimumZoomScale = rw;
    theWebView.scrollView.maximumZoomScale = rw;
    theWebView.scrollView.zoomScale = rw;
}

- (void)restoreButtonLabel{
    [printButton setTitle:urlToPrint.lastPathComponent forState:UIControlStateNormal];
}

- (IBAction)printButtonTapped:(id)sender{
    if ([self.delegate respondsToSelector:@selector(userWantsToPrint:sender:)]){
        [printButton setTitle:@"Print File" forState:UIControlStateNormal];
        [self.delegate userWantsToPrint:urlToPrint sender:self];
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
