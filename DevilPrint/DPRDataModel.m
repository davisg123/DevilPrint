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
NSArray *printerList;
NSString *streamerKey;

+(DPRDataModel*)sharedInstance {
    if (!gSharedInstance) {
        gSharedInstance = [[DPRDataModel alloc] init];
        // Path to the plist (in the application bundle)
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:
                          @"keys" ofType:@"plist"];
        
        // Build the array from the plist
        NSDictionary *keyDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        streamerKey = [keyDict valueForKey:@"streamerKey"];
        
    }
    return gSharedInstance;
}

#pragma mark printer info

-(NSArray *)printersNearLocation:(CLLocation *)myLocation{
    if (!printerList){
        return nil;
    }
    else if(!myLocation){
        return printerList;
    }
    else{
        printerList = [printerList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            DPRPrinter *printer1 = (DPRPrinter*)obj1;
            float distance1 = [myLocation distanceFromLocation:printer1.site.location];
            DPRPrinter *printer2 = (DPRPrinter*)obj2;
            float distance2 = [myLocation distanceFromLocation:printer2.site.location];
            if (distance1 > distance2){
                return NSOrderedDescending;
            }
            else if (distance1 < distance2){
                return NSOrderedAscending;
            }
            else{
                return NSOrderedSame;
            }
        }];
        return printerList;
    }
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
                    printerList = list;
                    completion(list,error);
                }
            }];
        }
    }];
}

-(void)allPrintersWithCompletion:(void(^)(NSArray *list, NSError *error))completion{
    NSString *urlString = [NSString stringWithFormat:@"https://streamer.oit.duke.edu/eprint/printers?access_token=%@",streamerKey];
    [self networkRequestWithURLString:urlString withCompletion:^(id response, NSError *error) {
        if (!error){
            NSArray *results = response;
            NSMutableArray *printers = [NSMutableArray new];
            for (int i=0;i<[results count];i++){
                NSDictionary *properties = [results objectAtIndex:i];
                //make sure this is a valid printer record
                if (![properties isKindOfClass:[NSDictionary class]]){
                    continue;
                }
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
                DPRStatus *status = [DPRStatus new];
                if ([[properties objectForKey:@"statuses"] count] != 0){
                    //printer status is a DPRStatus object
                    NSDictionary *statusDict = [[properties objectForKey:@"statuses"] objectAtIndex:0];
                    status.name = [statusDict objectForKey:@"name"];
                    status.severity = [statusDict objectForKey:@"severity"];
                    status.createdAt = [self stringToDate:[statusDict objectForKey:@"created_at"]];
                }
                printer.status = status;
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
        NSString *urlString = [NSString stringWithFormat:@"https://streamer.oit.duke.edu/eprint/sites?access_token=%@",streamerKey];
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
                    site.directions = [properties objectForKey:@"directions"] ?: @"";
                    site.retired = [properties objectForKey:@"retired"];
                    site.createdAt = [self stringToDate:[properties objectForKey:@"created_at"]];
                    site.updatedAt = [self stringToDate:[properties objectForKey:@"updated_at"]];
                    site.computers = [[properties objectForKey:@"computers"] boolValue];
                    id numPrinters = [properties objectForKey:@"printers"];
                    //sometimes this key has a null value
                    site.numPrinters = [numPrinters isKindOfClass:[NSNull class]] ? 0 : [numPrinters intValue];
                    site.location = [[CLLocation alloc] initWithLatitude:[[properties objectForKey:@"latitude"] doubleValue] longitude:[[properties objectForKey:@"longitude"] doubleValue]];
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

#pragma mark printer helper methods

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

#pragma mark file access

-(void)saveFile:(NSURL*)fileURL{
    NSError *error;
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *documentsPath = [[resourcePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = [fileURL lastPathComponent];
    NSString *joinedPathAndFile = [NSString stringWithFormat:@"%@/%@",documentsPath,fileName];
    NSURL *joinedPathAsURL = [NSURL fileURLWithPath:joinedPathAndFile];
    [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:joinedPathAsURL error:&error];
}

-(NSArray*)fileList{
    NSMutableArray *files = [NSMutableArray new];
    NSURL *documentsURL= [self applicationDocumentsDirectory];
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];
    NSArray *sortedFileList = [directoryContents sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *firstFile  = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", [documentsURL path], obj1] error:nil];
        NSDate *firstFileDate             = [firstFile  objectForKey:NSFileModificationDate];
        NSDictionary *secondFile = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", [documentsURL path], obj2] error:nil];
        NSDate *secondFileDate            = [secondFile objectForKey:NSFileModificationDate];
        return [secondFileDate compare:firstFileDate];
    }];
    for (int i=0;i<[sortedFileList count];i++){
        NSURL *fileURL = [sortedFileList objectAtIndex:i];
        NSString *filePath = [fileURL path];
        [files addObject:filePath];
        //max 10 files displayed
        if ([files count] == 10){
            break;
        }
    }
    return files;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *inboxURL = [documentsURL URLByAppendingPathComponent:@"Inbox"];
    return inboxURL;
}

@end
