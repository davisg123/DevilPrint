//
//  DPRPrintManager.m
//  DevilPrint
//
//  Created by Davis Gossage on 7/21/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import "DPRPrintManager.h"
#import "AFNetworking.h"

@implementation DPRPrintManager

@synthesize netId,copies,duplex,selectedPrinter,firstPage,lastPage,reverseOrder;

#define serviceEndpoint @"http://api.colab.duke.edu/api/eprint/1.0/print"

static DPRPrintManager* gSharedInstance = nil;

+(DPRPrintManager*)sharedInstance {
    if (!gSharedInstance) {
        gSharedInstance = [[DPRPrintManager alloc] init];
    }
    return gSharedInstance;
}

#pragma mark setter getter
//we want these values to be stored as user defaults as soon as they are set so they can be retrieved in future sessions
//think of these as permanent, persistant settings

- (void)setNetId:(NSString *)n{
    [[NSUserDefaults standardUserDefaults] setObject:n forKey:@"netId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)netId{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"netId"];
}

- (void)setCopies:(NSNumber*)c{
    [[NSUserDefaults standardUserDefaults] setObject:c forKey:@"copies"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber*)copies{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"copies"];
}

- (void)setDuplex:(BOOL)d{
    [[NSUserDefaults standardUserDefaults] setBool:d forKey:@"duplex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)duplex{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"duplex"];
}

- (void)setSelectedPrinter:(NSString *)s{
    [[NSUserDefaults standardUserDefaults] setObject:s forKey:@"selectedPrinter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)selectedPrinter{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedPrinter"];
}

- (void)setFirstPage:(NSNumber *)f{
    [[NSUserDefaults standardUserDefaults] setObject:f forKey:@"firstPage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber*)firstPage{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"firstPage"];
}

- (void)setLastPage:(NSNumber *)l{
    [[NSUserDefaults standardUserDefaults] setObject:l forKey:@"lastPage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber*)lastPage{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"lastPage"];
}

- (void)setReverseOrder:(BOOL)r{
    [[NSUserDefaults standardUserDefaults] setBool:r forKey:@"reverseOrder"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)reverseOrder{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"reverseOrder"];
}


#pragma mark api requests

-(void)printFileWithCompletion:(void (^)(NSError *))completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //gonna need some clarification on what happens if NSNulls get put in the dictionary
    NSDictionary *params = @{@"netid": netId,@"copies":copies,@"duplex":[NSNumber numberWithBool:duplex],@"printers":selectedPrinter,@"first_page":firstPage,@"last_page":lastPage,@"reverse_order":[NSNumber numberWithBool:reverseOrder]};
    
    [manager POST:serviceEndpoint parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //the file goes here
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error);
    }];
}

-(void)printUrlWithCompletion:(void (^)(NSError *))completion{
    //not implemented on server yet
}





@end
