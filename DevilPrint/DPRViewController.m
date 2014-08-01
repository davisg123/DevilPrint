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
#import "DPRPrinterTableViewCell.h"
#import "DPRFileCollectionViewCell.h"

@interface DPRViewController (){
    IBOutlet UITableView *printerTableView;
    IBOutlet UICollectionView *fileCollectionView;
    IBOutlet UICollectionView *tabCollectionView;           ///<secondary collection view for showing the tabs above files
    IBOutlet MKMapView *printerMapView;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

@end

@implementation DPRViewController

NSArray *printerList;
NSArray *fileList;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // move tableview content out of the way of the status bar
    [printerTableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    //get file list
    fileList = [[DPRDataModel sharedInstance] fileList];
    [fileCollectionView reloadData];
    
    [self startStandardLocationUpdates];
    printerMapView.delegate = self;
    printerMapView.showsUserLocation = true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            printerList = [[DPRDataModel sharedInstance] printersNearLocation:currentLocation];
            [printerTableView reloadData];
        }];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if([CLLocationManager locationServicesEnabled]){
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            //just fetch the normal old list of printers
        }
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
    float meters = [currentLocation distanceFromLocation:printer.site.location];
    float feet = meters * 3.28084;
    float miles = feet * 0.000189394;
    if (miles < 1){
        [cell setDLabel:[NSString stringWithFormat:@"%.0f f",feet]];
        return cell;
    }
    else{
        [cell setDLabel:[NSString stringWithFormat:@"%.01f m",miles]];
        return cell;
    }
}

#pragma mark collectionView data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == fileCollectionView){
        return [fileList count];
    }
    else{
        //it's the tab collection view
        return 3;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == fileCollectionView){
        DPRFileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fileCell" forIndexPath:indexPath];
        [cell showFile:[fileList objectAtIndex:indexPath.row]];
        return cell;
    }
    else{
        //it's the tab collection view
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tabCell" forIndexPath:indexPath];
        return cell;
    }
}



@end
