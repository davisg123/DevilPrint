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
}

@end

@implementation DPRFileCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareForReuse{
    [fileWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

- (void)showFile:(NSString *)fileString{
    fileWebView.delegate = self;
    NSURL *url = [NSURL fileURLWithPath:fileString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [fileWebView loadRequest:req];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
