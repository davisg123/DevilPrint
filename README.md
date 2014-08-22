#DevilPrint -  iOS
![DevilPrint Icon](http://imgur.com/FeGV99U.png)

**DevilPrint**, the official mobile ePrinting client of Duke University

##Getting Started
* Go to streamer.oit.duke.edu and create an API key with ePrint enabled
* Add the api key to the keys.plist file as the value for the key 'streamerKey'

##Data Model
The data model is responsible for getting and maintaining a list of printers and the associated information about them.

###Objects

* ####DPRPrinter
```
@property NSString* printerId;
@property NSString* type;
@property NSString* name;
@property NSString* brand;
@property NSString* model;
@property NSString* severity;
@property NSDate* createdAt;
@property NSDate* updatedAt;
@property DPRStatus* status;
@property DPRSite* site;
```
* ####DPRSite
```
@property NSString* siteId;
@property NSString* name;
@property NSString* campus;
@property NSString* building;
@property NSString* room;
@property NSString* directions;
@property CLLocation* location;
@property NSString* retired;
@property NSDate* createdAt;
@property NSDate* updatedAt;
@property BOOL computers;
@property int numPrinters;
```
* ####DPRStatus
```
@property NSString* name;
@property UIImage* image;
@property NSString* severity;
@property NSDate* createdAt;
```

###Methods
```
//get an array of all the printers
//completion block returns an array of DPRPrinter objects
-(void)populatePrinterListWithCompletion:(void(^)(NSArray *list, NSError *error))completion;
```
```
//sort the array of printers given a location
//printer list must be populated first
-(NSArray *)printersNearLocation:(CLLocation *)location;
```
The data model also manages the files that have been opened in the app.

```
//get a list of files from the app directory
-(NSArray *)fileList;
```

##Print Manager
The print manager handles printing and validating documents.

###Methods
```
//prints a file.  must pass in a local fileurl
-(void)printFile:(NSURL*)fileUrl WithCompletion:(void(^)(NSError *error))completion;
```
```
//validate a url including checking if sakai auth is needed.
-(void)validateUrl:(NSURL*)url withCompletion:(void (^)(NSError *))completion;
```
```
//print a url.  if the url points to a file it will be downloaded and sent as a param
-(void)printUrl:(NSURL*)url withCompletion:(void(^)(NSError *error))completion;
```
```
//calculate number of pages for a url.  only works for pdfs, other files return 0
-(int)numberOfPagesForFileUrl:(NSURL*)url;
```

#Interface
`DPRViewController` is the only view controller.  The top half of the view is a table with a list printers.  The bottom half of the view is a collection view showing documents in the file directory.  Below the printer tableview is a map which becomes unblurred when a printer is selected.  There's also a print sheet that goes on top of everything when the print button is tapped.












