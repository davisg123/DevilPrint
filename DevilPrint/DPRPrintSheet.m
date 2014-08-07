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
    IBOutlet UISegmentedControl *duplexSegment;
    IBOutlet UILabel            *copiesLabel;
    IBOutlet UIStepper          *copiesStepper;
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

- (void)fillExistingSettings{
    netIdTextField.text = [[DPRPrintManager sharedInstance] netId];
    copiesStepper.value = [[[DPRPrintManager sharedInstance] copies] doubleValue];
    [self stepperChangedValue:nil];
    duplexSegment.selectedSegmentIndex = [[DPRPrintManager sharedInstance] duplex] ? 1 : 0;
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
