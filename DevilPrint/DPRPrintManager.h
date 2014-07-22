//
//  DPRPrintManager.h
//  DevilPrint
//
//  Created by Davis Gossage on 7/21/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//


/*******************
 
 
 responsible for handling the connection and associated calls to devilprint's backend printing api
 
 
 ********************/

#import <Foundation/Foundation.h>

@interface DPRPrintManager : NSObject

//global paramaters
@property (nonatomic,retain) NSString *netId;                  ///required netId, validated by server
@property NSNumber *copies;                       ///optional copies to print, server default is 1
@property BOOL duplex;                      ///optional double sided option, server default is true
@property NSString *selectedPrinter;        ///optional selected printer. server default is to send the document to the entire eprint system
@property NSNumber *firstPage;                    ///optional start page. server default is 1
@property NSNumber *lastPage;                     ///optional last page.  server default is 99999
@property BOOL reverseOrder;                ///optional reverse ordering of pages.  server default is false

+(DPRPrintManager*)sharedInstance;

//TODO: this should accept the file or the file url
-(void)printFileWithCompletion:(void(^)(NSError *error))completion;

-(void)printUrlWithCompletion:(void(^)(NSError *error))completion;



@end
