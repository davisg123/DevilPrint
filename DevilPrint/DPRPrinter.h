//
//  DPRPrinter.h
//  DevilPrint
//
//  Created by Davis Gossage on 7/20/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPRStatus.h"
#import "DPRSite.h"

@interface DPRPrinter : NSObject

@property NSString* printerId;
@property NSString* type;
@property NSString* name;
@property NSString* brand;
@property NSString* model;
@property NSString* severity;
@property NSDate* createdAt;
@property NSDate* updatedAt;
@property DPRStatus* status;
@property DPRSite* site;


@end
