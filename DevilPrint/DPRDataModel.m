//
//  DPRDataModel.m
//  DevilPrint
//
//  Created by Davis Gossage on 7/20/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import "DPRDataModel.h"

@implementation DPRDataModel

static DPRDataModel* gSharedInstance = nil;

+(DPRDataModel*)sharedInstance {
    if (!gSharedInstance) {
        gSharedInstance = [[DPRDataModel alloc] init];
    }
    return gSharedInstance;
}

@end
