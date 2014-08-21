//
//  DPRPrintManager.h
//  DevilPrint
//
//  Created by Davis Gossage on 7/21/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//


/*******************
 
 
 responsible for handling the connection and associated calls to devilprint's backend printing api
 
 also does some file analysis, number of pages, tba
 
 
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
@property NSNumber *pagesPerSheet;          ///optional pages per sheet.  can be 1,2,4,6,9,16

+(DPRPrintManager*)sharedInstance;

//TODO: this should accept the file or the file url
-(void)printFile:(NSURL*)fileUrl WithCompletion:(void(^)(NSError *error))completion;

-(void)validateUrl:(NSURL*)url withCompletion:(void (^)(NSError *))completion;

-(void)printUrl:(NSURL*)url withCompletion:(void(^)(NSError *error))completion;

-(int)numberOfPagesForFileUrl:(NSURL*)url;



@end
