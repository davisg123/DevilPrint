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
#import "Flurry.h"

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
    
    [manager POST:serviceEndpoint parameters:[self globalParams] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //the file goes here
        [formData appendPartWithFileURL:fileUrl name:@"print_file" error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Flurry logEvent:@"Print_Success"];
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //see http://blog.gregfiumara.com/archives/239 for why the response is inside the NSError
        NSDictionary *dict = @{@"error": error};
        [Flurry logEvent:@"Print_Fail" withParameters:dict];
        completion(error);
    }];
}

-(void)printUrl:(NSURL*)url withCompletion:(void(^)(NSError *error))completion{
    if (url.pathExtension.length != 0){
        //this is a file, so treat it like one
        [self printFile:url WithCompletion:^(NSError *error) {
            completion(error);
        }];
    }
    else{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        // *** Use our custom response serializer ***
        manager.responseSerializer = [JSONResponseSerializerWithData serializer];
        //server api is documented at streamer.oit.duke.edu
        NSMutableDictionary *params = [[self globalParams] mutableCopy];
        [params setObject:[url absoluteString] forKey:@"URLKEYHERE"];
        [manager POST:serviceEndpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completion(nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(error);
        }];
    }
}

-(void)validateUrl:(NSURL*)url withCompletion:(void (^)(NSError *))completion{
    if (url && url.scheme && url.host){
        if ([url.host isEqualToString:@"sakai.duke.edu"]){
            if ([url.pathExtension length] != 0){
                BOOL __block redirectFlag = false;
                //it's sakai, so additional auth might be required through shiboleth
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:[url absoluteString] parameters:nil error:nil];
                AFHTTPRequestOperation *sakaiOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                [sakaiOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if (redirectFlag){
                        completion([self createErrorWithMessage:nil andCode:0]);
                    }
                    else{
                        completion(nil);
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    completion([self createErrorWithMessage:@"Failed to validate the url.  Check your internet connection." andCode:-1]);
                }];
                [sakaiOperation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
                    if ([redirectResponse.URL.host isEqualToString:@"shib.oit.duke.edu"]){
                        redirectFlag = true;
                    }
                    return request;
                }];
                [sakaiOperation start];
            }
            else{
                completion([self createErrorWithMessage:@"We can print Sakai URLs just fine, they just need to point to an actual file (.pdf, .docx, etc.)" andCode:-1]);
            }
        }
        else{
            //
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please copy the URL that you would like to print to the clipboard." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

-(NSDictionary*)globalParams{
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
    return params;
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


-(NSError*)createErrorWithMessage:(NSString*)message andCode:(NSInteger)code{
    if (!message){
        message = @"";
    }
    NSDictionary *errorMessage = @{NSLocalizedDescriptionKey: message};
    NSError *error = [NSError errorWithDomain:@"DevilPrint.printManager" code:code userInfo:errorMessage];
    return error;
}

@end
