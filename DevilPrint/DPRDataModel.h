//
//  DPRDataModel.h
//  DevilPrint
//
//  Created by Davis Gossage on 7/20/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//


/****************
 
 
 responsible for getting printers (all or nearby) and all associated information about them
 also handles the file directory, documents that are opened in the app go in this directory


*****************/

#import <Foundation/Foundation.h>
#import "DPRPrinter.h"
#import "DPRStatus.h"
#import "DPRSite.h"

@interface DPRDataModel : NSObject

+(DPRDataModel*)sharedInstance;

//get an array of all the printers
-(void)populatePrinterListWithCompletion:(void(^)(NSArray *list, NSError *error))completion;

//sort the array of printers given a location
//printer list must be populated first
-(NSArray *)printersNearLocation:(CLLocation *)location;

//get a list of files from the app directory
-(NSArray *)fileList;


@end
