//
//  DPRViewController.m
//  DevilPrint
//
//  Created by Davis Gossage on 7/20/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import "DPRViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "DPRDataModel.h"
#import "DPRPrintManager.h"
#import "DPRPrinterTableViewCell.h"
#import "FXBlurView.h"
#import "JSONResponseSerializerWithData.h"
#import "DPRPrintSheet.h"

@interface DPRViewController (){
    IBOutlet UITableView *printerTableView;
    IBOutlet UICollectionView *fileCollectionView;
    IBOutlet MKMapView *printerMapView;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    DPRPrintSheet *printSheetView;                          ///< popup for selecting options.  a drawer like a sliding thing, nothing is drawn
    FXBlurView *blurView;                                   ///< blur view shown behind print drawer
    IBOutlet FXBlurView *baseBlurView;                               ///< blur view shown behind printer table that blurs the map
    DPRFileCollectionViewCell *currentFileCell;             ///< the cell from which we are printing
    IBOutlet UIView *activityView;                                   ///< activity view showing when printers are being fetched
    NSArray *printerList;
    NSArray *printerListCopy;
    NSArray *fileList;
    NSMutableArray *indexPathArray;                         ///< an array containing the hidden printers when we are drilled down
    MKPointAnnotation *selectedPrinterAnnotation;           ///< annotation for the selected printer
}

@end

@implementation DPRViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // move tableview content out of the way of the status bar
    [printerTableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    
    fileList = [[DPRDataModel sharedInstance] fileList];
    [fileCollectionView reloadData];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFileList)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self startStandardLocationUpdates];
    printerMapView.delegate = self;
    printerMapView.showsUserLocation = true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateFileList{
    //update file list
    fileList = [[DPRDataModel sharedInstance] fileList];
    if ([fileList count] != [[[NSUserDefaults standardUserDefaults] objectForKey:@"files"] integerValue]){
        //new file has been found, show the print view
        [fileCollectionView reloadData];
        if ([fileList count] > 0){
            //reload data happens async, so give it 1 second before accessing new item
            [self performSelector:@selector(showNewItemAfterDelay) withObject:nil afterDelay:1.0];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[fileList count]] forKey:@"files"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showNewItemAfterDelay{
    NSIndexPath *firstCellPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [fileCollectionView scrollToItemAtIndexPath:firstCellPath atScrollPosition:UICollectionViewScrollPositionLeft animated:false];
    //simulate a print button tap on this cell
    DPRFileCollectionViewCell *cellToPrint = (DPRFileCollectionViewCell*)[fileCollectionView cellForItemAtIndexPath:firstCellPath];
    [cellToPrint printButtonTapped:nil];
}

#pragma mark location stuff

- (void)startStandardLocationUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (locationManager == nil){
        locationManager = [[CLLocationManager alloc] init];
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    locationManager.distanceFilter = 100;
    
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations lastObject];
    if (currentLocation.horizontalAccuracy >= 0) {
        MKCoordinateRegion mapRegion;
        mapRegion.center = currentLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.005;
        mapRegion.span.longitudeDelta = 0.005;
        
        [printerMapView setRegion:mapRegion animated: YES];
        [[DPRDataModel sharedInstance] populatePrinterListWithCompletion:^(NSArray *list, NSError *error) {
            //only animate changes if the printer list was previously 0
            if (!printerList){
                printerList = [[DPRDataModel sharedInstance] printersNearLocation:currentLocation];
                [printerTableView beginUpdates];
                //animate the rows being inserted
                NSMutableArray *indexPathsToAdd = [NSMutableArray new];
                for (int i=0;i<[printerList count];i++){
                    [indexPathsToAdd addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                [printerTableView insertRowsAtIndexPaths:indexPathsToAdd withRowAnimation:UITableViewRowAnimationFade];
                [self hideActivityView];
                [printerTableView endUpdates];
            }
            else{
                printerList = [[DPRDataModel sharedInstance] printersNearLocation:currentLocation];
                [self hideActivityView];
                [printerTableView reloadData];
            }
        }];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if([CLLocationManager locationServicesEnabled]){
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                               message:@"This app is a lot more useful when it knows where you are.  To re-enable, please go to Settings and turn on Location Service for this app."
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [alert show];
        }
        //just fetch the normal full list of printers
        [[DPRDataModel sharedInstance] populatePrinterListWithCompletion:^(NSArray *list, NSError *error) {
            //only animate changes if the printer list was previously 0
            if (!printerList){
                printerList = list;
                [printerTableView beginUpdates];
                //animate the rows being inserted
                NSMutableArray *indexPathsToAdd = [NSMutableArray new];
                for (int i=0;i<[printerList count];i++){
                    [indexPathsToAdd addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                [printerTableView insertRowsAtIndexPaths:indexPathsToAdd withRowAnimation:UITableViewRowAnimationFade];
                [self hideActivityView];
                [printerTableView endUpdates];
            }
            else{
                printerList = list;
                [self hideActivityView];
                [printerTableView reloadData];
            }
        }];
    }
}

#pragma mark tableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [printerList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DPRPrinterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"printerCell" forIndexPath:indexPath];
    DPRPrinter *printer = [printerList objectAtIndex:indexPath.row];
    [cell setPrinter:printer];
    if (currentLocation){
        float meters = [currentLocation distanceFromLocation:printer.site.location];
        float feet = meters * 3.28084;
        float miles = feet * 0.000189394;
        if (miles < 1){
            [cell setDLabel:[NSString stringWithFormat:@"%.0f f",feet]];
        }
        else{
            [cell setDLabel:[NSString stringWithFormat:@"%.01f m",miles]];
        }
    }
    return cell;
}

#pragma mark tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (!printerListCopy){
        //since we are drilled down, end location updates
        [locationManager stopUpdatingLocation];
        //figure out which printers are not selected, these will be deleted, leaving only the selected printer
        indexPathArray = [NSMutableArray new];
        for (int i=0;i<[printerList count];i++){
            //if this isn't the selected row, it should be deleted
            if (i != [indexPath row]){
                [indexPathArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        //begin animated row deletion
        [printerTableView beginUpdates];
        [printerTableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        //create a backup of all of the printers
        printerListCopy = [printerList mutableCopy];
        //make the printerlist, our data source, only contain the selected printer
        //it becomes a one element array
        DPRPrinter *selectedPrinter = [printerList objectAtIndex:indexPath.row];
        printerList = @[selectedPrinter];
        //finalize these changes
        [printerTableView endUpdates];
        //disable the separator since there is only one row
        printerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //animate hiding of the blur view
        [UIView animateWithDuration:.5 animations:^{
            baseBlurView.alpha = 0.0;
        }];
        if (selectedPrinter.site.location){
            //stick a pin on the map
            selectedPrinterAnnotation = [[MKPointAnnotation alloc] init];
            [selectedPrinterAnnotation setCoordinate:selectedPrinter.site.location.coordinate];
            [printerMapView addAnnotation:selectedPrinterAnnotation];
        }
    }
    else{
        //start location updates
        [locationManager startUpdatingLocation];
        //restore the printer list
        [printerTableView beginUpdates];
        [printerTableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        printerList = [printerListCopy mutableCopy];
        printerListCopy = nil;
        [printerTableView endUpdates];
        //enable the separator
        printerTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        //animate showing of the blur view
        [UIView animateWithDuration:.5 animations:^{
            baseBlurView.alpha = 1.0;
        }];
        if (selectedPrinterAnnotation){
            [printerMapView removeAnnotation:selectedPrinterAnnotation];
            selectedPrinterAnnotation = nil;
        }
    }
}

#pragma mark collectionView data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [fileList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DPRFileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fileCell" forIndexPath:indexPath];
    cell.delegate = self;
    [cell showFile:[fileList objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark DPRFileCollectionViewCellDelegate

- (IBAction)userWantsToPrint:(NSURL *)urlToPrint sender:(id)sender{
    currentFileCell = (DPRFileCollectionViewCell*)sender;
    
    if (printSheetView){
        //print dialog is already active, send to print manager
        //lock down print dialog and print button
        printSheetView.userInteractionEnabled = false;
        fileCollectionView.userInteractionEnabled = false;
        //make the cell show a spinner
        [currentFileCell printingDidStart];
        [[DPRPrintManager sharedInstance] printFile:urlToPrint WithCompletion:^(NSError *error) {
            if (error){
                NSDictionary *errorDescription = [error.userInfo objectForKey:JSONResponseSerializerWithDataKey];
                if ([errorDescription objectForKey:@"message"]){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[errorDescription objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"We're having some trouble talking to our server.  If it's not your connection it's probably us, and we're on it." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }
                [currentFileCell restoreButtonLabel];
                [self removePrintSheet];
            }
            else{
                //make the cell show a success message
                [currentFileCell flashSuccess];
                [self removePrintSheet];
            }
        }];
    }
    else{
        //lock down the collection view
        fileCollectionView.scrollEnabled = false;
        //blur the table and show the print dialog
        blurView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        blurView.dynamic = false;
        blurView.blurRadius = 20.0;
        blurView.tintColor = [UIColor clearColor];
        //detect tap in the blur view (this will hide the print drawer)
        UITapGestureRecognizer *backgroundTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleBackgroundTap:)];
        [blurView addGestureRecognizer:backgroundTap];
        
        
        printSheetView = [[[NSBundle mainBundle] loadNibNamed:@"DPRPrintSheet" owner:self options:nil] lastObject];
        printSheetView.center = CGPointMake(self.view.frame.size.width/2, printSheetView.frame.size.height/2+40);
        printSheetView.alpha = 0;
        [self.view insertSubview:printSheetView belowSubview:fileCollectionView];
        [printSheetView fillExistingSettings];
        int pages = [[DPRPrintManager sharedInstance] numberOfPagesForFileUrl:urlToPrint];
        //a 0 page count means we don't know it
        //this will hide the range selector
        [printSheetView constrainSliderToMinVal:1 MaxVal:pages];
        blurView.alpha = 0;
        [self.view insertSubview:blurView aboveSubview:printerTableView];
        [UIView animateWithDuration:0.5 animations:^{
            printSheetView.alpha = 1.0;
            blurView.alpha = 1.0;
        }];
    }
}

- (void)handleBackgroundTap:(UITapGestureRecognizer *)recognizer {
    if ([currentFileCell respondsToSelector:@selector(restoreButtonLabel)]){
        [currentFileCell restoreButtonLabel];
    }
    [self removePrintSheet];
}

- (void)removePrintSheet{
    [UIView animateWithDuration:.5 animations:^{
        printSheetView.alpha = 0.0;
        blurView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [printSheetView removeFromSuperview];
        [blurView removeFromSuperview];
        printSheetView = nil;
        blurView = nil;
    }];
    //reenable the scroll on the collection view
    fileCollectionView.scrollEnabled = true;
    fileCollectionView.userInteractionEnabled = true;
}

#pragma mark activity view

-(void)hideActivityView{
    [UIView animateWithDuration:.5 animations:^{
        activityView.alpha = 0.0;
    }];
}

@end
