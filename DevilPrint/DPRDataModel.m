//
//  DPRDataModel.m
//  DevilPrint
//
//  Created by Davis Gossage on 7/20/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import "DPRDataModel.h"
#import "AFNetworking.h"

@implementation DPRDataModel

static DPRDataModel* gSharedInstance = nil;
NSArray *allSites;

+(DPRDataModel*)sharedInstance {
    if (!gSharedInstance) {
        gSharedInstance = [[DPRDataModel alloc] init];
    }
    return gSharedInstance;
}

-(void)populatePrinterListWithCompletion:(void(^)(NSArray *list, NSError *error))completion{
    [self allSitesWithCompletion:^(NSError *error) {
        if (error){
            if (completion){
                completion(nil,error);
            }
        }
        else{
            [self allPrintersWithCompletion:^(NSArray *list, NSError *error) {
                if (completion){
                    completion(list,error);
                }
            }];
        }
    }];
}

-(void)allPrintersWithCompletion:(void(^)(NSArray *list, NSError *error))completion{
    NSString *urlString = [NSString stringWithFormat:@"https://streamer.oit.duke.edu/eprint/printers?access_token=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"streamerKey"]];
    [self networkRequestWithURLString:urlString withCompletion:^(id response, NSError *error) {
        if (!error){
            NSArray *results = response;
            NSMutableArray *printers = [NSMutableArray new];
            for (int i=0;i<[results count];i++){
                NSDictionary *properties = [results objectAtIndex:i];
                DPRPrinter *printer = [DPRPrinter new];
                //standard properties
                printer.printerId = [properties objectForKey:@"id"];
                printer.type = [properties objectForKey:@"type"];
                printer.name = [properties objectForKey:@"name"];
                printer.brand = [properties objectForKey:@"brand"];
                printer.model = [properties objectForKey:@"model"];
                printer.severity = [properties objectForKey:@"severity"];
                printer.createdAt = [self stringToDate:[properties objectForKey:@"created_at"]];
                printer.updatedAt = [self stringToDate:[properties objectForKey:@"updated_at"]];
                if ([[properties objectForKey:@"statuses"] count] != 0){
                    //printer status is a DPRStatus object
                    DPRStatus *status = [DPRStatus new];
                    NSDictionary *statusDict = [[properties objectForKey:@"statuses"] objectAtIndex:0];
                    status.name = [statusDict objectForKey:@"name"];
                    status.severity = [statusDict objectForKey:@"severity"];
                    status.createdAt = [self stringToDate:[statusDict objectForKey:@"created_at"]];
                    printer.status = status;
                }
                //printer site is a DPRSite object
                NSArray *siteIds = [allSites valueForKey:@"siteId"];
                //check this printer's site id against the list of all site ids
                NSInteger index = [siteIds indexOfObject:[properties objectForKey:@"site_id"]];
                //if theres a match, associate printer with this site
                printer.site = (index == NSNotFound) ? nil : [allSites objectAtIndex:index];
                [printers addObject:printer];
            }
            if (completion){
                completion(printers,nil);
            }
        }
        else{
            if (completion){
                completion(nil, error);
            }
        }
    }];
}

-(void)allSitesWithCompletion:(void(^)(NSError *error))completion{
    if ([allSites count] != 0){
        //no need to get sites again, these don't change
        completion(nil);
    }
    else{
        NSString *urlString = [NSString stringWithFormat:@"https://streamer.oit.duke.edu/eprint/sites?access_token=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"streamerKey"]];
        [self networkRequestWithURLString:urlString withCompletion:^(id response, NSError *error) {
            if (!error){
                NSArray *results = response;
                NSMutableArray *sites = [NSMutableArray new];
                for (int i=0;i<[results count];i++){
                    NSDictionary *properties = [results objectAtIndex:i];
                    DPRSite *site = [DPRSite new];
                    //standard properties
                    site.siteId = [properties objectForKey:@"id"];
                    site.name = [properties objectForKey:@"name"];
                    site.campus = [properties objectForKey:@"campus"];
                    site.building = [properties objectForKey:@"building"];
                    site.room = [properties objectForKey:@"room"];
                    site.directions = [properties objectForKey:@"directions"];
                    site.retired = [properties objectForKey:@"retired"];
                    site.createdAt = [self stringToDate:[properties objectForKey:@"created_at"]];
                    site.updatedAt = [self stringToDate:[properties objectForKey:@"updated_at"]];
                    site.computers = [[properties objectForKey:@"computers"] boolValue];
                    id numPrinters = [properties objectForKey:@"printers"];
                    //sometimes this key has a null value
                    site.numPrinters = [numPrinters isKindOfClass:[NSNull class]] ? 0 : [numPrinters intValue];
                    [sites addObject:site];
                }
                allSites = sites;
            }
            if (completion){
                completion(error);
            }
        }];
    }
}

-(void)networkRequestWithURLString:(NSString*)urlString withCompletion:(void(^)(id response, NSError *error))completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(completion){
            completion(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(completion){
            completion(nil,error);
        }
    }];
}

-(NSDate*)stringToDate:(NSString*)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    // voila!
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    
    return dateFromString;
}

@end
