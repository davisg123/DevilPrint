//
//  DPRPrintDrawer.m
//  DevilPrint
//
//  Created by Davis Gossage on 8/4/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import "DPRPrintSheet.h"
#import "NMRangeSlider.h"
#import "DPRPrintManager.h"

@interface DPRPrintSheet(){
    IBOutlet UITextField        *netIdTextField;
    IBOutlet NMRangeSlider      *pageRangeSlider;
    IBOutlet UILabel            *pageRangeLowerLabel;
    IBOutlet UILabel            *pageRangeUpperLabel;
    IBOutlet UISegmentedControl *duplexSegment;
    IBOutlet UILabel            *copiesLabel;
    IBOutlet UIStepper          *copiesStepper;
    IBOutlet UISegmentedControl *pagesPerSheetSegment;
}

@end

@implementation DPRPrintSheet

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    //save the value to the print manager
    [[DPRPrintManager sharedInstance] setNetId:netIdTextField.text];
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return true;
}

- (IBAction)stepperChangedValue:(id)sender{
    [[DPRPrintManager sharedInstance] setCopies:[NSNumber numberWithDouble:copiesStepper.value]];
    NSString *copyFormat = (int)copiesStepper.value == 1 ? @"Copy" : @"Copies";
    copiesLabel.text = [NSString stringWithFormat:@"%d %@", (int)copiesStepper.value,copyFormat];
}

- (IBAction)duplexSegmentChangedValue:(id)sender{
    //if the selected segment is 1 (the duplex segment) then duplex is true, otherwise false
    [DPRPrintManager sharedInstance].duplex = duplexSegment.selectedSegmentIndex == 1 ? true : false;
}

- (IBAction)pagesPerSheetChangedValue:(id)sender{
    //get pages per sheet by looking at the text label on the segment
    int pps = [[pagesPerSheetSegment titleForSegmentAtIndex:pagesPerSheetSegment.selectedSegmentIndex] integerValue];
    [[DPRPrintManager sharedInstance] setPagesPerSheet:@(pps)];
}

- (void)constrainSliderToMinVal:(int)min MaxVal:(int)max{
    //default is to print all pages
    [[DPRPrintManager sharedInstance] setFirstPage:nil];
    [[DPRPrintManager sharedInstance] setLastPage:nil];
    if (max <= 1){
        //can't show the slider for 1 page
        //0 means we don't know how many pages
        pageRangeUpperLabel.hidden = true;
        pageRangeLowerLabel.hidden = true;
        pageRangeSlider.hidden = true;
    }
    else{
        pageRangeSlider.hidden = false;
        pageRangeLowerLabel.hidden = false;
        pageRangeUpperLabel.hidden = false;
        //put your floaties on
        //that was stupid, i'm tired
        pageRangeSlider.minimumValue = (float)min;
        pageRangeSlider.maximumValue = (float)max;
        pageRangeSlider.lowerValue = (float)min;
        pageRangeSlider.upperValue = (float)max;
        [self updateSliderLabels];
    }
}

- (void)updateSliderLabels
{
    // You get get the center point of the slider handles and use this to arrange other subviews
    CGPoint lowerCenter;
    lowerCenter.x = (pageRangeSlider.lowerCenter.x + pageRangeSlider.frame.origin.x);
    lowerCenter.y = (pageRangeSlider.center.y - 30.0f);
    pageRangeLowerLabel.center = lowerCenter;
    pageRangeLowerLabel.text = [NSString stringWithFormat:@"%d", (int)pageRangeSlider.lowerValue];
    
    CGPoint upperCenter;
    upperCenter.x = (pageRangeSlider.upperCenter.x + pageRangeSlider.frame.origin.x);
    upperCenter.y = (pageRangeSlider.center.y - 30.0f);
    pageRangeUpperLabel.center = upperCenter;
    pageRangeUpperLabel.text = [NSString stringWithFormat:@"%d", (int)pageRangeSlider.upperValue];
    
    //weird syntax incoming
    //@ is a shortcut for nsnumber numberwithint
    [[DPRPrintManager sharedInstance] setFirstPage:@((int)pageRangeSlider.lowerValue)];
    [[DPRPrintManager sharedInstance] setLastPage:@((int)pageRangeSlider.upperValue)];
}

// Handle control value changed events just like a normal slider
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender
{
    [self updateSliderLabels];
}

- (void)fillExistingSettings{
    netIdTextField.text = [[DPRPrintManager sharedInstance] netId];
    copiesStepper.value = [[[DPRPrintManager sharedInstance] copies] doubleValue];
    [self stepperChangedValue:nil];
    duplexSegment.selectedSegmentIndex = [[DPRPrintManager sharedInstance] duplex] ? 1 : 0;
    //set the pages per sheet back to 1, don't want that to default
    pagesPerSheetSegment.selectedSegmentIndex = 0;
    [[DPRPrintManager sharedInstance] setPagesPerSheet:nil];
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
