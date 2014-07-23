//
//  DPRStatus.h
//  DevilPrint
//
//  Created by Davis Gossage on 7/21/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STATUSONLINEIMAGE @"status_ok.png"
#define STATUSOFFLINEIMAGE @"status_no_connection.png"
#define STATUSWARNINGIMAGE @"status_warning.png"
#define STATUSPAPERLOWIMAGE @"status_low_paper.png"
#define STATUSTONERLOWIMAGE @"status_low_ink.png"
#define STATUSOUTOFORDERIMAGE @"status_out_of_order.png"

@interface DPRStatus : NSObject

@property NSString* name;
@property UIImage* image;
@property NSString* severity;
@property NSDate* createdAt;

@end
