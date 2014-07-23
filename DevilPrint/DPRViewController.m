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

@interface DPRViewController (){
    IBOutlet UITableView *printerTableView;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

@end

@implementation DPRViewController

NSArray *printerList;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // move tableview content out of the way of the status bar
    [printerTableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    [self startStandardLocationUpdates];
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
    
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations lastObject];
    [[DPRDataModel sharedInstance] populatePrinterListWithCompletion:^(NSArray *list, NSError *error) {
        printerList = [[DPRDataModel sharedInstance] printersNearLocation:currentLocation];
        [printerTableView reloadData];
    }];
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



@end
