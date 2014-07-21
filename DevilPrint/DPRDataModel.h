//
//  DPRDataModel.h
//  DevilPrint
//
//  Created by Davis Gossage on 7/20/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPRPrinter.h"
#import "DPRStatus.h"
#import "DPRSite.h"

@interface DPRDataModel : NSObject

+(DPRDataModel*)sharedInstance;

//get an array of all the printers
-(void)populatePrinterListWithCompletion:(void(^)(NSArray *list, NSError *error))completion;


@end
