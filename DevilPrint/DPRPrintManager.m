//
//  DPRPrintManager.m
//  DevilPrint
//
//  Created by Davis Gossage on 7/21/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import "DPRPrintManager.h"
#import "AFNetworking.h"
#import "JSONResponseSerializerWithData.h"

@implementation DPRPrintManager

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

- (void)setPagesPerSheet:(NSNumber *)p{
    [[NSUserDefaults standardUserDefaults] setObject:p forKey:@"pagesPerSheet"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber*)pagesPerSheet{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"pagesPerSheet"];
}


#pragma mark api requests

-(void)printFile:(NSURL*)fileUrl WithCompletion:(void(^)(NSError *error))completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // *** Use our custom response serializer ***
    manager.responseSerializer = [JSONResponseSerializerWithData serializer];
    //server api is documented at streamer.oit.duke.edu
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if (self.netId){
        [params setObject:self.netId forKey:@"netid"];
    }
    if (self.copies){
        [params setObject:self.copies forKey:@"copies"];
    }
    if (self.duplex){
        [params setObject:[NSNumber numberWithBool:self.duplex] forKey:@"duplex"];
    }
    if (self.selectedPrinter){
        [params setObject:self.selectedPrinter forKey:@"printers"];
    }
    if (self.firstPage){
        [params setObject:self.firstPage forKey:@"first_page"];
    }
    if (self.lastPage){
        [params setObject:self.lastPage forKey:@"last_page"];
    }
    if (self.reverseOrder){
        [params setObject:[NSNumber numberWithBool:self.reverseOrder] forKey:@"reverse_order"];
    }
    if (self.pagesPerSheet){
        [params setObject:self.pagesPerSheet forKey:@"number_up"];
    }
    
    [manager POST:serviceEndpoint parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //the file goes here
        [formData appendPartWithFileURL:fileUrl name:@"print_file" error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //see http://blog.gregfiumara.com/archives/239 for why the response is inside the NSError
        completion(error);
    }];
}

-(void)printUrlWithCompletion:(void (^)(NSError *))completion{
    //not implemented on server yet
}


-(int)numberOfPagesForFileUrl:(NSURL *)url{
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
    if(pdf){
        return CGPDFDocumentGetNumberOfPages(pdf);
    }
    else{
        return 0;
    }
}




@end
